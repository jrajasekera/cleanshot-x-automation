-- Save the current macOS clipboard image to a file.
-- Prefers PNG clipboard data; falls back to TIFF + sips conversion for PNG outputs.

on run argv
    if (count of argv) is less than 1 then
        error "Usage: osascript clipboard-image-to-file.applescript /path/to/output.png" number 2
    end if

    set outPath to item 1 of argv

    try
        set pngData to the clipboard as «class PNGf»
        my writeDataToFile(pngData, outPath)
        return outPath
    on error pngErr
        try
            set tiffData to the clipboard as «class TIFF»
            if my endsWith(outPath, ".tif") or my endsWith(outPath, ".tiff") then
                my writeDataToFile(tiffData, outPath)
                return outPath
            else
                set tmpPath to outPath & ".tiff"
                my writeDataToFile(tiffData, tmpPath)
                do shell script "/usr/bin/sips -s format png " & quoted form of tmpPath & " --out " & quoted form of outPath & " >/dev/null"
                do shell script "/bin/rm -f " & quoted form of tmpPath
                return outPath
            end if
        on error tiffErr
            error "Clipboard does not contain a PNG or TIFF image. PNG error: " & pngErr & "; TIFF error: " & tiffErr number 1
        end try
    end try
end run

on writeDataToFile(theData, outPath)
    set outFile to open for access POSIX file outPath with write permission
    try
        set eof outFile to 0
        write theData to outFile
        close access outFile
    on error errMsg number errNum
        try
            close access outFile
        end try
        error errMsg number errNum
    end try
end writeDataToFile

on endsWith(theText, theSuffix)
    set textLength to length of theText
    set suffixLength to length of theSuffix
    if suffixLength is greater than textLength then return false
    return text -suffixLength thru -1 of theText is theSuffix
end endsWith
