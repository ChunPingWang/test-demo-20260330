package com.example.customer;

import com.lowagie.text.Document;
import com.lowagie.text.Element;
import com.lowagie.text.PageSize;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Phrase;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.apache.poi.xwpf.usermodel.*;
import org.junit.jupiter.api.Test;

import java.awt.Color;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;

class ApiDocumentGenerator {

    record ApiInfo(String method, String path, String description, String requestBody, String responseBody, String statusCode) {}

    private static final List<ApiInfo> APIS = List.of(
            new ApiInfo("GET", "/api/customers", "Get all customers", "None",
                    "[{id, name, email, phone, address, createdAt, updatedAt}]", "200 OK"),
            new ApiInfo("GET", "/api/customers/{id}", "Get customer by ID", "None",
                    "{id, name, email, phone, address, createdAt, updatedAt}", "200 OK"),
            new ApiInfo("POST", "/api/customers", "Create a new customer",
                    "{name*, email*, phone, address}", "{id, name, email, phone, address, createdAt, updatedAt}", "201 Created"),
            new ApiInfo("PUT", "/api/customers/{id}", "Update customer by ID",
                    "{name*, email*, phone, address}", "{id, name, email, phone, address, createdAt, updatedAt}", "200 OK"),
            new ApiInfo("DELETE", "/api/customers/{id}", "Delete customer by ID", "None", "None", "204 No Content")
    );

    private static final String DOCS_DIR = "docs";

    @Test
    void generateAllDocuments() throws Exception {
        Files.createDirectories(Path.of(DOCS_DIR));
        generateMarkdown();
        generateWord();
        generateExcel();
        generatePdf();
        System.out.println("All API documents generated in docs/ directory.");
    }

    private void generateMarkdown() throws Exception {
        StringBuilder sb = new StringBuilder();
        sb.append("# Customer Management API Documentation\n\n");
        sb.append("Base URL: `http://localhost:8080`\n\n");
        sb.append("## API List\n\n");
        sb.append("| # | Method | Path | Description | Request Body | Response Body | Status Code |\n");
        sb.append("|---|--------|------|-------------|--------------|---------------|-------------|\n");
        for (int i = 0; i < APIS.size(); i++) {
            ApiInfo api = APIS.get(i);
            sb.append("| ").append(i + 1).append(" | ").append(api.method).append(" | `").append(api.path)
                    .append("` | ").append(api.description).append(" | ").append(api.requestBody)
                    .append(" | ").append(api.responseBody).append(" | ").append(api.statusCode).append(" |\n");
        }

        sb.append("\n## Data Model\n\n");
        sb.append("### Customer\n\n");
        sb.append("| Field | Type | Required | Description |\n");
        sb.append("|-------|------|----------|-------------|\n");
        sb.append("| id | Long | Auto | Primary key |\n");
        sb.append("| name | String(50) | Yes | Customer name |\n");
        sb.append("| email | String(100) | Yes | Email (unique) |\n");
        sb.append("| phone | String(20) | No | Phone number |\n");
        sb.append("| address | String(200) | No | Address |\n");
        sb.append("| createdAt | DateTime | Auto | Creation time |\n");
        sb.append("| updatedAt | DateTime | Auto | Last update time |\n");

        sb.append("\n## Example\n\n");
        sb.append("### Create Customer\n\n");
        sb.append("```json\n");
        sb.append("POST /api/customers\n");
        sb.append("Content-Type: application/json\n\n");
        sb.append("{\n");
        sb.append("  \"name\": \"John Doe\",\n");
        sb.append("  \"email\": \"john@example.com\",\n");
        sb.append("  \"phone\": \"0912345678\",\n");
        sb.append("  \"address\": \"Taipei, Taiwan\"\n");
        sb.append("}\n");
        sb.append("```\n");

        try (FileWriter writer = new FileWriter(DOCS_DIR + "/api-documentation.md")) {
            writer.write(sb.toString());
        }
    }

    private void generateWord() throws Exception {
        try (XWPFDocument document = new XWPFDocument()) {
            XWPFParagraph title = document.createParagraph();
            title.setAlignment(ParagraphAlignment.CENTER);
            XWPFRun titleRun = title.createRun();
            titleRun.setText("Customer Management API Documentation");
            titleRun.setBold(true);
            titleRun.setFontSize(18);

            XWPFParagraph baseUrl = document.createParagraph();
            XWPFRun baseUrlRun = baseUrl.createRun();
            baseUrlRun.setText("Base URL: http://localhost:8080");
            baseUrlRun.setFontSize(11);

            XWPFParagraph apiSection = document.createParagraph();
            apiSection.setSpacingBefore(200);
            XWPFRun apiSectionRun = apiSection.createRun();
            apiSectionRun.setText("API List");
            apiSectionRun.setBold(true);
            apiSectionRun.setFontSize(14);

            XWPFTable table = document.createTable(APIS.size() + 1, 7);
            table.setWidth("100%");

            String[] headers = {"#", "Method", "Path", "Description", "Request Body", "Response Body", "Status Code"};
            XWPFTableRow headerRow = table.getRow(0);
            for (int j = 0; j < headers.length; j++) {
                XWPFRun run = headerRow.getCell(j).getParagraphs().get(0).createRun();
                run.setText(headers[j]);
                run.setBold(true);
                run.setFontSize(9);
            }

            for (int i = 0; i < APIS.size(); i++) {
                ApiInfo api = APIS.get(i);
                XWPFTableRow row = table.getRow(i + 1);
                String[] values = {String.valueOf(i + 1), api.method, api.path, api.description,
                        api.requestBody, api.responseBody, api.statusCode};
                for (int j = 0; j < values.length; j++) {
                    XWPFRun run = row.getCell(j).getParagraphs().get(0).createRun();
                    run.setText(values[j]);
                    run.setFontSize(9);
                }
            }

            XWPFParagraph modelSection = document.createParagraph();
            modelSection.setSpacingBefore(200);
            XWPFRun modelRun = modelSection.createRun();
            modelRun.setText("Data Model - Customer");
            modelRun.setBold(true);
            modelRun.setFontSize(14);

            String[][] fields = {
                    {"id", "Long", "Auto", "Primary key"},
                    {"name", "String(50)", "Yes", "Customer name"},
                    {"email", "String(100)", "Yes", "Email (unique)"},
                    {"phone", "String(20)", "No", "Phone number"},
                    {"address", "String(200)", "No", "Address"},
                    {"createdAt", "DateTime", "Auto", "Creation time"},
                    {"updatedAt", "DateTime", "Auto", "Last update time"}
            };

            XWPFTable modelTable = document.createTable(fields.length + 1, 4);
            modelTable.setWidth("100%");
            String[] modelHeaders = {"Field", "Type", "Required", "Description"};
            XWPFTableRow mHeaderRow = modelTable.getRow(0);
            for (int j = 0; j < modelHeaders.length; j++) {
                XWPFRun run = mHeaderRow.getCell(j).getParagraphs().get(0).createRun();
                run.setText(modelHeaders[j]);
                run.setBold(true);
                run.setFontSize(9);
            }
            for (int i = 0; i < fields.length; i++) {
                XWPFTableRow row = modelTable.getRow(i + 1);
                for (int j = 0; j < fields[i].length; j++) {
                    XWPFRun run = row.getCell(j).getParagraphs().get(0).createRun();
                    run.setText(fields[i][j]);
                    run.setFontSize(9);
                }
            }

            try (FileOutputStream out = new FileOutputStream(DOCS_DIR + "/api-documentation.docx")) {
                document.write(out);
            }
        }
    }

    private void generateExcel() throws Exception {
        try (org.apache.poi.ss.usermodel.Workbook workbook = new XSSFWorkbook()) {
            org.apache.poi.ss.usermodel.CellStyle headerStyle = workbook.createCellStyle();
            org.apache.poi.ss.usermodel.Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerFont.setFontHeightInPoints((short) 11);
            headerStyle.setFont(headerFont);
            headerStyle.setFillForegroundColor(org.apache.poi.ss.usermodel.IndexedColors.LIGHT_CORNFLOWER_BLUE.getIndex());
            headerStyle.setFillPattern(org.apache.poi.ss.usermodel.FillPatternType.SOLID_FOREGROUND);
            headerStyle.setBorderBottom(org.apache.poi.ss.usermodel.BorderStyle.THIN);
            headerStyle.setBorderTop(org.apache.poi.ss.usermodel.BorderStyle.THIN);
            headerStyle.setBorderLeft(org.apache.poi.ss.usermodel.BorderStyle.THIN);
            headerStyle.setBorderRight(org.apache.poi.ss.usermodel.BorderStyle.THIN);

            org.apache.poi.ss.usermodel.CellStyle dataStyle = workbook.createCellStyle();
            dataStyle.setBorderBottom(org.apache.poi.ss.usermodel.BorderStyle.THIN);
            dataStyle.setBorderTop(org.apache.poi.ss.usermodel.BorderStyle.THIN);
            dataStyle.setBorderLeft(org.apache.poi.ss.usermodel.BorderStyle.THIN);
            dataStyle.setBorderRight(org.apache.poi.ss.usermodel.BorderStyle.THIN);

            org.apache.poi.ss.usermodel.Sheet apiSheet = workbook.createSheet("API List");
            String[] apiHeaders = {"#", "Method", "Path", "Description", "Request Body", "Response Body", "Status Code"};

            org.apache.poi.ss.usermodel.Row titleRow = apiSheet.createRow(0);
            org.apache.poi.ss.usermodel.Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue("Customer Management API Documentation");
            org.apache.poi.ss.usermodel.CellStyle titleStyle = workbook.createCellStyle();
            org.apache.poi.ss.usermodel.Font titleFont = workbook.createFont();
            titleFont.setBold(true);
            titleFont.setFontHeightInPoints((short) 14);
            titleStyle.setFont(titleFont);
            titleCell.setCellStyle(titleStyle);
            apiSheet.addMergedRegion(new CellRangeAddress(0, 0, 0, 6));

            org.apache.poi.ss.usermodel.Row hRow = apiSheet.createRow(2);
            for (int i = 0; i < apiHeaders.length; i++) {
                org.apache.poi.ss.usermodel.Cell cell = hRow.createCell(i);
                cell.setCellValue(apiHeaders[i]);
                cell.setCellStyle(headerStyle);
            }

            for (int i = 0; i < APIS.size(); i++) {
                ApiInfo api = APIS.get(i);
                org.apache.poi.ss.usermodel.Row row = apiSheet.createRow(i + 3);
                String[] values = {String.valueOf(i + 1), api.method, api.path, api.description,
                        api.requestBody, api.responseBody, api.statusCode};
                for (int j = 0; j < values.length; j++) {
                    org.apache.poi.ss.usermodel.Cell cell = row.createCell(j);
                    cell.setCellValue(values[j]);
                    cell.setCellStyle(dataStyle);
                }
            }

            for (int i = 0; i < apiHeaders.length; i++) {
                apiSheet.autoSizeColumn(i);
            }

            org.apache.poi.ss.usermodel.Sheet modelSheet = workbook.createSheet("Data Model");
            String[] modelHeaders = {"Field", "Type", "Required", "Description"};

            org.apache.poi.ss.usermodel.Row mTitleRow = modelSheet.createRow(0);
            org.apache.poi.ss.usermodel.Cell mTitleCell = mTitleRow.createCell(0);
            mTitleCell.setCellValue("Customer Data Model");
            mTitleCell.setCellStyle(titleStyle);
            modelSheet.addMergedRegion(new CellRangeAddress(0, 0, 0, 3));

            org.apache.poi.ss.usermodel.Row mhRow = modelSheet.createRow(2);
            for (int i = 0; i < modelHeaders.length; i++) {
                org.apache.poi.ss.usermodel.Cell cell = mhRow.createCell(i);
                cell.setCellValue(modelHeaders[i]);
                cell.setCellStyle(headerStyle);
            }

            String[][] fields = {
                    {"id", "Long", "Auto", "Primary key"},
                    {"name", "String(50)", "Yes", "Customer name"},
                    {"email", "String(100)", "Yes", "Email (unique)"},
                    {"phone", "String(20)", "No", "Phone number"},
                    {"address", "String(200)", "No", "Address"},
                    {"createdAt", "DateTime", "Auto", "Creation time"},
                    {"updatedAt", "DateTime", "Auto", "Last update time"}
            };
            for (int i = 0; i < fields.length; i++) {
                org.apache.poi.ss.usermodel.Row row = modelSheet.createRow(i + 3);
                for (int j = 0; j < fields[i].length; j++) {
                    org.apache.poi.ss.usermodel.Cell cell = row.createCell(j);
                    cell.setCellValue(fields[i][j]);
                    cell.setCellStyle(dataStyle);
                }
            }
            for (int i = 0; i < modelHeaders.length; i++) {
                modelSheet.autoSizeColumn(i);
            }

            try (FileOutputStream out = new FileOutputStream(DOCS_DIR + "/api-documentation.xlsx")) {
                workbook.write(out);
            }
        }
    }

    private void generatePdf() throws Exception {
        Document document = new Document(PageSize.A4.rotate());
        PdfWriter.getInstance(document, new FileOutputStream(DOCS_DIR + "/api-documentation.pdf"));
        document.open();

        com.lowagie.text.Font titleFont = new com.lowagie.text.Font(com.lowagie.text.Font.HELVETICA, 18, com.lowagie.text.Font.BOLD);
        com.lowagie.text.Font sectionFont = new com.lowagie.text.Font(com.lowagie.text.Font.HELVETICA, 14, com.lowagie.text.Font.BOLD);
        com.lowagie.text.Font headerFont = new com.lowagie.text.Font(com.lowagie.text.Font.HELVETICA, 9, com.lowagie.text.Font.BOLD, Color.WHITE);
        com.lowagie.text.Font cellFont = new com.lowagie.text.Font(com.lowagie.text.Font.HELVETICA, 9);

        Paragraph title = new Paragraph("Customer Management API Documentation", titleFont);
        title.setAlignment(Element.ALIGN_CENTER);
        title.setSpacingAfter(10);
        document.add(title);

        Paragraph baseUrl = new Paragraph("Base URL: http://localhost:8080", cellFont);
        baseUrl.setSpacingAfter(15);
        document.add(baseUrl);

        Paragraph apiSection = new Paragraph("API List", sectionFont);
        apiSection.setSpacingAfter(10);
        document.add(apiSection);

        PdfPTable table = new PdfPTable(7);
        table.setWidthPercentage(100);
        table.setWidths(new float[]{1, 2, 4, 4, 4, 5, 3});

        Color headerBg = new Color(51, 122, 183);
        String[] headers = {"#", "Method", "Path", "Description", "Request Body", "Response Body", "Status Code"};
        for (String h : headers) {
            PdfPCell cell = new PdfPCell(new Phrase(h, headerFont));
            cell.setBackgroundColor(headerBg);
            cell.setPadding(5);
            table.addCell(cell);
        }

        for (int i = 0; i < APIS.size(); i++) {
            ApiInfo api = APIS.get(i);
            String[] values = {String.valueOf(i + 1), api.method, api.path, api.description,
                    api.requestBody, api.responseBody, api.statusCode};
            Color rowBg = (i % 2 == 0) ? Color.WHITE : new Color(240, 240, 240);
            for (String v : values) {
                PdfPCell cell = new PdfPCell(new Phrase(v, cellFont));
                cell.setBackgroundColor(rowBg);
                cell.setPadding(4);
                table.addCell(cell);
            }
        }
        document.add(table);

        document.add(new Paragraph(" "));
        Paragraph modelSection = new Paragraph("Data Model - Customer", sectionFont);
        modelSection.setSpacingAfter(10);
        document.add(modelSection);

        PdfPTable modelTable = new PdfPTable(4);
        modelTable.setWidthPercentage(60);
        modelTable.setHorizontalAlignment(Element.ALIGN_LEFT);

        String[] modelHeaders = {"Field", "Type", "Required", "Description"};
        for (String h : modelHeaders) {
            PdfPCell cell = new PdfPCell(new Phrase(h, headerFont));
            cell.setBackgroundColor(headerBg);
            cell.setPadding(5);
            modelTable.addCell(cell);
        }

        String[][] fields = {
                {"id", "Long", "Auto", "Primary key"},
                {"name", "String(50)", "Yes", "Customer name"},
                {"email", "String(100)", "Yes", "Email (unique)"},
                {"phone", "String(20)", "No", "Phone number"},
                {"address", "String(200)", "No", "Address"},
                {"createdAt", "DateTime", "Auto", "Creation time"},
                {"updatedAt", "DateTime", "Auto", "Last update time"}
        };
        for (int i = 0; i < fields.length; i++) {
            Color rowBg = (i % 2 == 0) ? Color.WHITE : new Color(240, 240, 240);
            for (String v : fields[i]) {
                PdfPCell cell = new PdfPCell(new Phrase(v, cellFont));
                cell.setBackgroundColor(rowBg);
                cell.setPadding(4);
                modelTable.addCell(cell);
            }
        }
        document.add(modelTable);

        document.close();
    }
}
