CommandLine = {}

local COMMAND = "/perhourcontinued"

function CommandLine:Init()
    SLASH_PERHOURCONTINUED1 = COMMAND
    SlashCmdList["PERHOURCONTINUED"] = function(msg)
        if msg == "credits" then
            print("PerHour |cFFAB9DF2Continued|r by |cFFAB9DF2tylxr|r (Discord: |cFFAB9DF2@tylxr59|r / Website: |cFFAB9DF2tylxr.com|r)")
            print("Visit us on GitHub - |cFFAB9DF2https://github.com/tylxr59/PerHour_Continued|r")
        else
            print("Unknown command. Available commands: credits")
        end
    end
end

CommandLine:Init()