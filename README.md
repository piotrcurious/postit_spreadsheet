# postit_spreadsheet
lightweight spreadsheet, for tasks where mere calculator is not enough . Dreamed by gpt4o

# Spreadsheet App

A simple Post-it note style spreadsheet application using Tcl/Tk with TclOO extensions and lambdas, implementing inter-cell relations. This app allows you to create cells, set relationships between them, and save/load the spreadsheet.

## Features

- **Add Cell**: Create a new cell in the spreadsheet.
- **Set Relation**: Define relationships between cells using expressions.
- **Save Spreadsheet**: Save the current spreadsheet to a JSON file.
- **Load Spreadsheet**: Load a spreadsheet from a JSON file.

## Getting Started

### Prerequisites

- Tcl/Tk installed on your system.
- The `json` package for Tcl installed.

### Running the Application

1. Save the script to a file, e.g., `spreadsheet_app.tcl`.
2. Run the script using Tcl:
    ```sh
    tclsh spreadsheet_app.tcl
    ```

## Code Structure and Design

### Class: SpreadsheetApp

The main application class that handles the creation and management of cells.

#### Variables
- `cells`: Stores the cell widgets and their associated expressions.
- `cellValues`: Stores the current values of each cell.

#### Methods

- **constructor {w}**: Initializes the main window and UI elements.
- **addCell {w {id {}}}**: Adds a new cell to the window. If `id` is not provided, a new ID is generated.
- **setRelation {id entry}**: Sets the relationship between cells by prompting the user to select a target cell and enter an expression.
- **updateCells {}**: Updates all cells based on the defined relationships.
- **saveSpreadsheet {w}**: Saves the current spreadsheet to a JSON file.
- **loadSpreadsheet {w}**: Loads a spreadsheet from a JSON file.

### UI Components

- **Main Window**: The main application window.
- **Menu Frame**: Contains buttons for adding cells, saving, and loading the spreadsheet.
- **Cells Frame**: Contains the dynamically added cells.

### Interaction Flow

1. **Add Cell**: Click the "Add Cell" button to create a new cell. Each cell consists of a label, an entry widget for value input, and a "Set Relation" button.
2. **Set Relation**: Click the "Set Relation" button of a cell to define its relationship with another cell. The user is prompted to select a target cell and enter an expression.
3. **Save Spreadsheet**: Click the "Save" button to save the current state of the spreadsheet to a JSON file.
4. **Load Spreadsheet**: Click the "Load" button to load a saved spreadsheet from a JSON file.

## Example Usage

1. Add a few cells using the "Add Cell" button.
2. Set relationships between cells using the "Set Relation" button.
3. Save the spreadsheet using the "Save" button.
4. Load the spreadsheet using the "Load" button to restore the saved state.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.


v2 :
Enhancements:Evaluate Expressions: Added a method evaluateExpression to map cell references and evaluate the expressions, allowing more complex relationships like summing cells in a row.Update Cells: Enhanced the updateCells method to evaluate and update cell values based on the defined expressions.Save and Load: Retained and improved save and load functionality to handle complex expressions.Usage for Complex Relations:To reference another cell in an expression, use the format $cell<ID>. For example, to sum cells with IDs 1, 2, and 3, use the expression "$cell1 + $cell2 + $cell3".With these improvements, the spreadsheet app can handle more complex cell relations, including summing and other arithmetic operations.

v3:
Enhancements:Order of Execution: Maintains an orderOfExecution list to ensure cells are updated in the correct order based on dependencies.Deleting Cells: Added a deleteCell method to remove cells from the UI and the internal state.Graphical Cell Management: Uses a grid layout to manage cell positions and sizes. Cells are added in rows with proper resizing and alignment.Improved Relation Setting: Simplified the setRelation method to directly prompt for expressions.Notes:Order of Execution: Ensures that cells are updated in the correct sequence based on their dependencies.Grid Layout: Ensures cells are properly aligned and resized within the grid.Expression Evaluation: Uses a regular expression-based substitution to handle cell references within expressions.This code now supports complex cell relations, dynamic addition and deletion of cells, and a more robust UI layout and management system.

v4:
Enhancements:Loading Cells from File: The loadSpreadsheet method now allows loading cells from an external file, supporting any cell order.Monitoring File Changes: The monitorFileChanges method monitors changes to the file and reloads the spreadsheet if it detects modifications.File Locking: Uses fileutil::lock for exclusive file access to prevent concurrent modifications.Quick Local Copy: Ensures that the file is not accessed while being updated by locking the file during read/write operations.Notes:The monitorFileChanges method periodically checks the file modification time and reloads the spreadsheet if changes are detected.The fileutil::lock package ensures that the file is locked during reading and writing to prevent concurrent access issues.The filename variable stores the path to the current spreadsheet file, and fileLastModified keeps track of the last modification time.

v5:
Features:Basic Arithmetic Operations: Allows basic arithmetic operations directly in cells.Cell References: Supports referencing other cells using $cell<ID> notation.Auto-Recalculate: Automatically recalculates dependent cells when a cell value changes.Common Functions: Supports basic functions like SUM and AVERAGE.Error Handling: Handles and displays errors in expressions gracefully.File Monitoring: Monitors changes to the external file and reloads if it detects modifications.File Locking: Uses file locking to prevent concurrent access during read/write operations.Notes:The evaluateExpression method now includes basic support for SUM and AVERAGE functions.The onCellValueChange method is bound to each cell's entry widget to automatically recalculate dependent cells when a cell value changes.The loadSpreadsheet method locks the file during reading to ensure safe access.The monitorFileChanges method periodically checks the file modification time and reloads the spreadsheet if changes are detected.
