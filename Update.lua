require "import"
import "android.widget.*"
import "android.view.*"
import "android.content.*"
import "android.net.Uri"
import "com.androlua.*"
import "java.net.URL"
import "java.io.BufferedReader"
import "java.io.InputStreamReader"

--------------------------------------------------
-- AUTO UPDATE SYSTEM
--------------------------------------------------

local currentVersion = "1.0"

local versionUrl = "https://raw.githubusercontent.com/BlindTechMalik/Test/main/Version.txt"
local notesUrl = "https://raw.githubusercontent.com/BlindTechMalik/Test/main/notes.txt"
local updateUrl = "https://raw.githubusercontent.com/BlindTechMalik/Test/main/Update.lua"

-- Download text from URL
function getUrlData(url)
  local success, result = pcall(function()
    local conn = URL(url).openConnection()
    conn.connect()

    local reader = BufferedReader(
      InputStreamReader(conn.getInputStream())
    )

    local data = ""
    local line

    while true do
      line = reader.readLine()
      if line == nil then
        break
      end
      data = data .. line .. "\n"
    end

    reader.close()
    return data
  end)

  if success then
    return result
   else
    return nil
  end
end

-- Save update file
function saveUpdate(code)
  local path = activity.getLuaDir().."/main.lua"

  local file = io.open(path, "w")
  file:write(code)
  file:close()
end

-- Check for updates
function checkUpdate()

  local onlineVersion = getUrlData(versionUrl)

  if onlineVersion then
    onlineVersion = onlineVersion:gsub("\n",""):gsub(" ","")

    if onlineVersion ~= currentVersion then

      local notes = getUrlData(notesUrl) or "No update notes"
      local newCode = getUrlData(updateUrl)

      AlertDialog.Builder(activity)
      .setTitle("New Update Available")
      .setMessage(
      "Current Version: "..currentVersion..
      "\nNew Version: "..onlineVersion..
      "\n\nUpdate Notes:\n"..notes
      )
      .setPositiveButton("Update",{
        onClick=function()

          if newCode then
            saveUpdate(newCode)

            Toast.makeText(
            activity,
            "Update Installed Successfully!\nRestart App",
            Toast.LENGTH_LONG
            ).show()

           else
            Toast.makeText(
            activity,
            "Failed To Download Update",
            Toast.LENGTH_LONG
            ).show()
          end

        end
      })
      .setNegativeButton("Later",nil)
      .show()

    end
  end
end

--------------------------------------------------
-- SOCIAL MEDIA TOOL
--------------------------------------------------

-- Function to generate each social media section
function createSection(platform, hint, baseUrl)
  return {
    {
      TextView,
      text = platform,
      textSize = "18sp",
      textStyle = "bold",
      layout_marginTop = "16dp"
    },

    {
      EditText,
      id = platform:lower().."Input",
      hint = hint
    },

    {
      LinearLayout,
      orientation = "horizontal",
      layout_width = "fill",

      {
        Button,
        text = "Copy Link",
        layout_weight = "1",

        onClick = function()

          local input = _G[platform:lower().."Input"].text

          if input ~= "" then

            local link = baseUrl..input

            activity
            .getSystemService(Context.CLIPBOARD_SERVICE)
            .setText(link)

            Toast.makeText(
            activity,
            "Link copied!",
            1
            ).show()

           else

            Toast.makeText(
            activity,
            "Please enter input",
            1
            ).show()

          end
        end
      },

      {
        Button,
        text = "Open Profile",
        layout_weight = "1",

        onClick = function()

          local input = _G[platform:lower().."Input"].text

          if input ~= "" then

            local link = baseUrl..input

            local intent = Intent(
            Intent.ACTION_VIEW,
            Uri.parse(link)
            )

            activity.startActivity(intent)

           else

            Toast.makeText(
            activity,
            "Please enter input",
            1
            ).show()

          end
        end
      },

      {
        Button,
        text = "Share Link",
        layout_weight = "1",

        onClick = function()

          local input = _G[platform:lower().."Input"].text

          if input ~= "" then

            local link = baseUrl..input

            local intent = Intent(Intent.ACTION_SEND)

            intent.setType("text/plain")
            intent.putExtra(Intent.EXTRA_TEXT, link)

            activity.startActivity(
            Intent.createChooser(intent, "Share Link")
            )

           else

            Toast.makeText(
            activity,
            "Please enter input",
            1
            ).show()

          end
        end
      },

      {
        Button,
        text = "Clear",
        layout_weight = "1",

        onClick = function()
          _G[platform:lower().."Input"].setText("")
        end
      }
    }
  }
end

--------------------------------------------------
-- MAIN LAYOUT
--------------------------------------------------

layout = {
  ScrollView,
  layout_width = "fill",
  layout_height = "fill",

  {
    LinearLayout,
    orientation = "vertical",
    padding = "16dp",
    layout_width = "fill",
    layout_height = "wrap",
  }
}

-- Add all sections dynamically
sections = {

  {
    "WhatsApp",
    "Enter WhatsApp number",
    "https://wa.me/"
  },

  {
    "Instagram",
    "Enter Instagram username",
    "https://instagram.com/"
  },

  {
    "Telegram",
    "Enter Telegram username",
    "https://t.me/"
  },

  {
    "Twitter",
    "Enter Twitter ID",
    "https://twitter.com/"
  },

  {
    "TikTok",
    "Enter TikTok username",
    "https://www.tiktok.com/@"
  },

  {
    "YouTube",
    "Enter channel handle",
    "https://www.youtube.com/@"
  }
}

for _, s in ipairs(sections) do
  for _, view in ipairs(
    createSection(s[1], s[2], s[3])
  ) do
    table.insert(layout[2], view)
  end
end

--------------------------------------------------
-- SHOW DIALOG
--------------------------------------------------

dlg = LuaDialog(this)

dlg.setTitle("Social Media Links Generator")
dlg.setMessage("Create Links")

dlg.setView(loadlayout(layout))

dlg.setButton("Close", nil)

dlg.show()

--------------------------------------------------
-- START UPDATE CHECK
--------------------------------------------------

checkUpdate()
