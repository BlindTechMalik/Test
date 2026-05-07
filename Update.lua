require "import"
import "android.widget.*"
import "android.view.*"
import "android.content.*"
import "android.net.Uri"
import "com.androlua.*"

-- Function to generate each social media section
function createSection(platform, hint, baseUrl)
  return {
    { TextView, text = platform, textSize = "18sp", textStyle = "bold", layout_marginTop = "16dp" },
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
            Toast.makeText(activity, "Link copied!", 1).show()
          else
            Toast.makeText(activity, "Please enter input", 1).show()
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
            Toast.makeText(activity, "Please enter input", 1).show()
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
            activity.startActivity(Intent.createChooser(intent, "Share Link"))
          else
            Toast.makeText(activity, "Please enter input", 1).show()
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

-- Main layout
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
  {"WhatsApp", "Enter WhatsApp number", "https://wa.me/"},
  {"Instagram", "Enter Instagram username", "https://instagram.com/"},
  {"Telegram", "Enter Telegram username", "https://t.me/"},
  {"Twitter", "Enter Twitter ID", "https://twitter.com/"},
  {"TikTok", "Enter TikTok username", "https://www.tiktok.com/@"},
  {"YouTube", "Enter channel handle", "https://www.youtube.com/@"}
}

for _, s in ipairs(sections) do
  for _, view in ipairs(createSection(s[1], s[2], s[3])) do
    table.insert(layout[2], view)
  end
end

-- Show dialog
dlg = LuaDialog(this)
dlg.setTitle("Social Media Links Generator")
dlg.setMessage("Create Links")
dlg.setView(loadlayout(layout))
dlg.setButton("Close", nil)
dlg.show()
