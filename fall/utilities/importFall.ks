@lazyglobal off.
global importFall to fallImportManager().

// fallImportManager :: nothing -> delegate
function fallImportManager {
    local modulePath is scriptpath() + "/../..".
    local moduleDirs is list("/controllers/", "/models/", "/utilities/").

    function getPath {
        parameter fileName.

        local result is "".
        for dir in moduleDirs {
            local filePath is modulePath + dir + fileName.
            if exists(filePath) { set result to filePath. break. }
        }

        if result = "" { throwException(fileName). }
        return result.
    }

    function throwException {
        parameter fileName.
        print "[ERORR] FALLIMPORT: " + fileName + " file doesn't exist".
    }

    function runFile {
        parameter fileName,
                  copyTo is "".

        local filePath is getPath(fileName).

        if filePath = "" { return false. }

        if not copyTo = ""
        {
            copypath(filePath, copyTo).
            set filePath to copyTo.
        }

        runpath(filePath).
        return true.
    }

    return runFile@.
}
