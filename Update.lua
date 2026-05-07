require "import"
import "android.widget.*"
import "android.view.*"
import "android.content.*"
import "android.net.Uri"
import "android.app.AlertDialog" -- یہ لائن ایڈ کی گئی ہے
import "com.androlua.*"
import "java.io.File"

-- گٹ ہب لنکس
local version_url = "https://raw.githubusercontent.com/BlindTechMalik/Test/refs/heads/main/Version.txt"
local notes_url = "https://raw.githubusercontent.com/BlindTechMalik/Test/refs/heads/main/notes.txt"
local update_code_url = "https://raw.githubusercontent.com/BlindTechMalik/Test/refs/heads/main/Update.lua"

-- آپ کے ٹول کا موجودہ ورژن
local current_version = "1.0"

-- ٹرم (Trim) کرنے کا فنکشن
local function trim(s)
  if s then return s:gsub("^%s*(.-)%s*$", "%1") else return "" end
end

-- اپڈیٹ چیک کرنے کا فنکشن
function checkUpdate(isManual)
  Http.get(version_url, function(code, content)
    if code == 200 then
      local new_version = trim(content) 
      
      if new_version ~= current_version then
        Http.get(notes_url, function(n_code, n_content)
          local update_notes = n_code == 200 and n_content or "New update available!"
          
          -- ڈائیلاگ بنانے کا درست طریقہ
          local dl = AlertDialog.Builder(activity)
          dl.setTitle("Update Available: v"..new_version)
          dl.setMessage(update_notes)
          dl.setCancelable(false)
          dl.setPositiveButton("Update Now", {
            onClick = function()
              Http.get(update_code_url, function(u_code, u_content)
                if u_code == 200 then
                  io.open(activity.getLuaDir().."/main.lua", "w"):write(u_content):close()
                  Toast.makeText(activity, "Updated! Restarting...", 1).show()
                  activity.recreate()
                else
                  Toast.makeText(activity, "Download failed!", 0).show()
                end
              end)
            end
          })
          dl.setNegativeButton("Maybe Later", nil)
          dl.show()
        end)
      else
        if isManual then
          Toast.makeText(activity, "No updates available.", 1).show()
        end
      end
    else
      if isManual then
        Toast.makeText(activity, "Error connecting to server.", 0).show()
      end
    end
  end)
end

-- سوشل میڈیا سیکشنز کا فنکشن
function createSection(platform, hint, baseUrl)
  return {
    { TextView, text = platform, textSize = "18sp", textStyle = "bold", padding="5dp" },
    { EditText, id = platform:lower().."Input", hint = hint },
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
            activity.getSystemService(Context.CLIPBOARD_SERVICE).setText(link)
            Toast.makeText(activity, "Link copied!", 0).show()
          else
            Toast.makeText(activity, "Please enter input", 0).show()
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
            local intent = Intent(Intent.ACTION_VIEW, Uri.parse(link))
            activity.startActivity(intent)
          else
            Toast.makeText(activity, "Please enter input", 0).show()
          end
        end
      }
    }
  }
end

-- مین لے آؤٹ
main_layout = {
  ScrollView,
  layout_width = "fill",
  layout_height = "fill",
  {
    LinearLayout,
    orientation = "vertical",
    padding = "16dp",
    layout_width = "fill",
    id = "scroll_container",
    { TextView, text = "Current Version: "..current_version, layout_gravity="center", textColor=0xFF757575 },
    { LinearLayout, orientation="vertical", id="mainContent", layout_width="fill" },
    {
      Button,
      text = "Check For Update",
      layout_width = "fill",
      layout_marginTop = "30dp",
      onClick = function()
        checkUpdate(true)
      end
    }
  }
}

activity.setContentView(loadlayout(main_layout))

sections = {
  {"WhatsApp", "Enter number", "https://wa.me/"},
  {"Instagram", "Enter username", "https://instagram.com/"},
  {"Telegram", "Enter username", "https://t.me/"},
  {"YouTube", "Enter handle", "https://www.youtube.com/@"}
}

for _, s in ipairs(sections) do
  local item_views = createSection(s[1], s[2], s[3])
  for _, v_table in ipairs(item_views) do
    local view = loadlayout(v_table)
    local lp = LinearLayout.LayoutParams(-1, -2)
    lp.setMargins(0, 10, 0, 10) 
    view.setLayoutParams(lp)
    mainContent.addView(view)
  end
end

-- اسٹارٹ اپ چیک
checkUpdate(false)
