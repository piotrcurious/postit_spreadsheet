package require TclOO

# Mock Tk and json/fileutil
proc toplevel {w} { proc $w {cmd args} { } }
proc frame {w args} { proc $w {cmd args} { }; return $w }
proc label {w args} { proc $w {cmd args} { }; return $w }
set entryValues {}
proc entry {w args} {
    global entryValues
    set entryValues($w) ""
    proc $w {cmd args} {
        global entryValues
        set w [lindex [info level 0] 0]
        switch -- $cmd {
            get { return $entryValues($w) }
            insert { set entryValues($w) [lrange $args 1 end] }
            delete { set entryValues($w) "" }
            configure { }
            trace { }
        }
    }
    return $w
}
proc button {w args} { proc $w {cmd args} { }; return $w }
proc pack {args} { }
proc grid {args} { }
proc wm {args} { }
proc tk_getOpenFile {args} { return "" }
proc tk_getSaveFile {args} { return "" }
proc tk_messageBox {args} { }
proc after {delay script} { }

oo::class create SpreadsheetApp {
    variable cells
    variable cellValues
    variable orderOfExecution
    variable nextRow
    variable filename
    variable fileLastModified

    constructor {w} {
        set cells {}
        array set cellValues {}
        set orderOfExecution {}
        set nextRow 0
        set filename ""
        set fileLastModified 0
    }

    method addCell {w {id {}}} {
        if {$id eq ""} {
            set id [expr {[array size cells] + 1}]
        }
        set frame .f$id
        set entry .e$id
        frame $frame
        entry $entry
        set cells($id) [list $frame $entry {}]
        lappend orderOfExecution $id
        incr nextRow
    }

    method setRelationExplicit {id expr} {
        set entry [lindex $cells($id) 1]
        set cells($id) [list [lindex $cells($id) 0] $entry $expr]
        my updateCells
    }

    method evaluateExpression {expr} {
        set mappedExpr $expr
        foreach id [array names cells] {
            set entry [lindex $cells($id) 1]
            set value [$entry get]
            # Potential bug: $cell1 matches $cell10
            regsub -all {\$cell$id} $mappedExpr $value mappedExpr
        }
        # Evaluate basic functions like SUM and AVERAGE
        if {[regexp {SUM\(([^)]+)\)} $mappedExpr -> args]} {
            set sum 0
            foreach arg [split $args ","] {
                set sum [expr {$sum + $arg}]
            }
            set mappedExpr [regsub -all {SUM\([^)]+\)} $mappedExpr $sum]
        }
        # Simplified eval
        return [expr $mappedExpr]
    }

    method updateCells {} {
        foreach id $orderOfExecution {
            if {[info exists cells($id)]} {
                set entry [lindex $cells($id) 1]
                set expr [lindex $cells($id) 2]
                if {$expr ne {}} {
                    set val [my evaluateExpression $expr]
                    $entry delete 0 end
                    $entry insert 0 $val
                    set cellValues($id) $val
                }
            }
        }
    }

    method getCellValue {id} {
        set entry [lindex $cells($id) 1]
        return [$entry get]
    }
}

SpreadsheetApp create app .app
app addCell .app 1
app addCell .app 2
app addCell .app 3

# Set cell 1 to 10
.e1 insert 0 10
# Set cell 2 to 20
.e2 insert 0 20

# Set cell 3 = $cell1 + $cell2
app setRelationExplicit 3 {$cell1 + $cell2}

puts "Cell 3 value: [app getCellValue 3]"

# Test for $cell10 vs $cell1 issue
app addCell .app 10
.e10 insert 0 500
app setRelationExplicit 3 {$cell10}
puts "Cell 3 with \$cell10: [app getCellValue 3]"

# If it works, it should be 500. If it's buggy, it might replace $cell1 first and get 100.
