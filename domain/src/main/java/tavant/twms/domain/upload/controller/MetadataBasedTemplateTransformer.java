/*
 *   Copyright (c)2007 Tavant Technologies
 *   All Rights Reserved.
 *
 *   This software is furnished under a license and may be used and copied
 *   only  in  accordance  with  the  terms  of such  license and with the
 *   inclusion of the above copyright notice. This software or  any  other
 *   copies thereof may not be provided or otherwise made available to any
 *   other person. No title to and ownership of  the  software  is  hereby
 *   transferred.
 *
 *   The information in this software is subject to change without  notice
 *   and  should  not be  construed as a commitment  by Tavant Technologies.
 */

package tavant.twms.domain.upload.controller;

import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFRichTextString;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;

/**
 * @author surajdeo.prasad
 *
 */
public class MetadataBasedTemplateTransformer extends TemplateTransformer {
	
	@SuppressWarnings("unchecked")
	public UploadStatusDetail transform(InputStream file, FileOutputStream out, 
			long fileUploadMgtId, int maxRowsAllowed, UploadManagement currentDataUpload,List<UploadManagementMetaData> uploadManagementMetaDatas)
			throws IOException {
		int totalCols = currentDataUpload.getColumnsToCapture()!=null?
				currentDataUpload.getColumnsToCapture().intValue():0;
		
		UploadManagementMetaData uploadManagementMetaData = null;
				
		Long rowsToStartConsuming = currentDataUpload.getConsumeRowsFrom();
		Long headerRowToConsume = currentDataUpload.getHeaderRowToCapture();
		UploadStatusDetail uploadStatus = new UploadStatusDetail();
		uploadStatus.setTotalRecords(0);
		uploadStatus.setSuccessRecords(0);
		uploadStatus.setErrorRecords(0);
		HSSFWorkbook wb = new HSSFWorkbook(file);
		HSSFSheet inSheet = wb.getSheetAt(0);

		HSSFWorkbook outWB = new HSSFWorkbook();
		String sheetName = getStagingTable();
		HSSFSheet outSheet = outWB.createSheet(sheetName);
		int rowIndex = 0;
		int createRowIndex = 0;
		int totalRows = inSheet.getLastRowNum();
		List dateColsIndex = new ArrayList();
		
		if ((totalRows-rowsToStartConsuming+1) > maxRowsAllowed) {
			uploadStatus.setUploadStatus(UploadStatusDetail.STATUS_FAILED);
			uploadStatus.setErrorMessage(
					"Unable to process the file as it has more than " + maxRowsAllowed + " records.");
			uploadStatus.setTotalRecords(totalRows-rowsToStartConsuming.intValue()+1);
			return uploadStatus;
		}
		if (totalRows < rowsToStartConsuming) {
			uploadStatus.setUploadStatus(UploadStatusDetail.STATUS_FAILED);
			uploadStatus.setErrorMessage("Invalid template");
			return uploadStatus;
		}
		
		while (rowIndex <= totalRows) {
			HSSFRow inRow = (HSSFRow) inSheet.getRow(rowIndex);
			try {
				String lastCol = inSheet.getRow(headerRowToConsume.intValue()).
									getCell((totalCols-1)).getStringCellValue();
				if("end of template".equalsIgnoreCase(lastCol.trim()))
					totalCols--;
			}catch (Exception e) {
			}
			// Header and Data rows; Ignore in between rows
			if (rowIndex==headerRowToConsume.intValue() || rowIndex >= rowsToStartConsuming.intValue()) 
			{
				HSSFRow outRow = outSheet.createRow(createRowIndex++);
				
				// Iterator colIterator = inRow.cellIterator();
				int colIndex = 0;
				int createColIndex = 0;
				StringBuffer errorCode = new StringBuffer();
				
				HSSFCell outCell = outRow.createCell(createColIndex++);
				if (rowIndex == headerRowToConsume.intValue())
					outCell.setCellValue("id");
				else
					outCell.setCellValue(""+createRowIndex);

				// To maintain the foreign key relationship with the staging tables
				outCell = outRow.createCell(createColIndex++);
				if (rowIndex == headerRowToConsume.intValue())
					outCell.setCellValue("FILE_UPLOAD_MGT_ID");
				else
					outCell.setCellValue(""+fileUploadMgtId);

				while (colIndex < totalCols) {
					HSSFCell inCell = (HSSFCell) inRow .getCell(colIndex);
					if (colIndex > 0 ) {
						uploadManagementMetaData = uploadManagementMetaDatas.get(colIndex - 1);
						outCell = outRow
								.createCell(createColIndex++);
						if (inCell != null) {
							if (inCell.getCellType() == HSSFCell.CELL_TYPE_STRING) {
								String stringCellValue = inCell.getStringCellValue();
								if(stringCellValue!=null)
									stringCellValue=stringCellValue.trim();

								if (rowIndex == headerRowToConsume.intValue()) {
									// TODO: If you have some columns which is different from database. Please have it
									// Readme: If you have some columns which is different from database. Please have it
									if ("Order #".equals(stringCellValue))
										outCell.setCellValue("Order_No");
									else if ("Replaced Non OEM parts description".equalsIgnoreCase(stringCellValue))
										outCell.setCellValue("Replaced_Non_OEM_parts_desc");
									else if ("Is part installed on host machine".equals(stringCellValue))
										outCell.setCellValue("IS_PART_INSTALLED_WITH_MACHINE");
									else
										outCell.setCellValue(stringCellValue.replace(" ", "_"));
									if (stringCellValue.toLowerCase().contains("date")) {
										dateColsIndex.add(colIndex);
									}
								} else if (rowIndex>=rowsToStartConsuming) {
									if(uploadManagementMetaData.getColumnType().equals("Date")) {
										try {
											new SimpleDateFormat("yyyyMMdd").parse(stringCellValue);
										}catch (ParseException e) {
											generateErrorCode(errorCode, "FORMAT_"
													+ colIndex);
										}
									}
									else if(uploadManagementMetaData.getColumnType().equals("Number")) {
										try {
											Integer.parseInt(stringCellValue);										
										}catch (NumberFormatException e) {
											generateErrorCode(errorCode, "FORMAT_"
													+ colIndex);
										}
									}
									outCell.setCellValue(stringCellValue);
								}
									
							} else if (inCell.getCellType() == HSSFCell.CELL_TYPE_NUMERIC) {
								//check if the cell has a date value
								if(uploadManagementMetaData.getColumnType().equals("Date")) {
									if (isDate(inCell))	{
										Date date = inCell.getDateCellValue();									
										String cellVal = new SimpleDateFormat("yyyyMMdd").format(date);
										outCell.setCellValue(cellVal);								
									} else {
										generateErrorCode(errorCode, "FORMAT_"
												+ colIndex);
									}
								} else if(uploadManagementMetaData.getColumnType().equals("Number")) {
									if (isNumber(inCell))	{
										outCell.setCellValue(inCell.getNumericCellValue());						
									} else {
										generateErrorCode(errorCode, "FORMAT_"
												+ colIndex);
									}
								}else  if(uploadManagementMetaData.getColumnType().equals("Text")) {
									outCell.setCellValue(new HSSFRichTextString(""+
											new Double(inCell.getNumericCellValue()).longValue()));
								}else {
									generateErrorCode(errorCode, "FORMAT_"
											+ colIndex);
								}
							}
						}
					}
					colIndex++;
				}
				//if rowIndex =headerrow, add error_status,error_code
				outCell = outRow.createCell(createColIndex++);
				if (rowIndex == headerRowToConsume.intValue()){
					outCell.setCellValue("ERROR_STATUS");
				}else {
					if(errorCode.length() > 0) {
						outCell.setCellValue("N");
					}
				}
				outCell = outRow.createCell(createColIndex++);
				if (rowIndex == headerRowToConsume.intValue()){
					outCell.setCellValue("ERROR_CODE");
				}else {
					if(errorCode.length() > 0) {
						outCell.setCellValue(errorCode.toString());
					}
				}
			}
			rowIndex++;
		}
		// handle error code column
		HSSFSheet sheet0 = outWB.getSheetAt(0);
		HSSFRow row0 = sheet0.getRow(0);
		int lastCellIndex = row0.getLastCellNum() - 1;
		if ("Error_Code".equals(row0.getCell(lastCellIndex)
				.getStringCellValue())) {
			int lastRowIndex = sheet0.getLastRowNum();
			for (int i = 1; i < lastRowIndex; i++) {
				HSSFCell cell = sheet0.getRow(i).getCell(lastCellIndex);
				sheet0.getRow(i).removeCell(cell);
			}
		}
		outWB.write(out);
		file.close();
		out.close();
		//uploadStatus.setUploadStatus(UploadStatusDetail.STATUS_VALIDATING);
		uploadStatus.setTotalRecords(rowIndex-rowsToStartConsuming.intValue());
		
		return uploadStatus;
	}

	private void generateErrorCode(StringBuffer errorCode, String code) {
		if(errorCode.length() == 0)
			errorCode.append(code);
		else 
			errorCode.append(";").append(code);
	}


}