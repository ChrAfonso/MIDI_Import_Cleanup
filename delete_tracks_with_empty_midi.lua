function println(msg)
  reaper.ShowConsoleMsg(msg .. "\n")
end

local numSelectedTracks = reaper.CountSelectedTracks(0)
local tracksToDelete = {}
for t = 0,numSelectedTracks-1 do
  local track = reaper.GetTrack(0, t)
  local numItems = reaper.CountTrackMediaItems(track)
  local notesInTrack = false
  for i= 0,numItems-1 do
    local item = reaper.GetTrackMediaItem(track, i)
    local numTakes = reaper.GetMediaItemNumTakes(item)
    if numTakes > 0 then
      println("Track " .. t .. " item " .. i)
      local take = reaper.GetMediaItemTake(item, 0)
      local source = reaper.GetMediaItemTake_Source(take)
      local sourceType = reaper.GetMediaSourceType(source, "")
      if sourceType == "MIDI" then
        -- TODO check if item is embedded in project file?
        
        -- TODO: Use this to remove empty midi items?
        local retval, notecnt, ccevtcnt, textsyxevtcnt = reaper.MIDI_CountEvts(take)
        println("  Midi events: [" .. notecnt .. "," .. ccevtcnt .. "," .. textsyxevtcnt .. "]")
        
        if notecnt > 0 then
          notesInTrack = true
        end
      end
    end
  end
  
  if notesInTrack == false then
    println("  * Marking track to delete")
    table.insert(tracksToDelete, track)
  end
end

for _,track in ipairs(tracksToDelete) do
  local retval, name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
  println("Deleting empty track " .. name)
  reaper.DeleteTrack(track)
end
