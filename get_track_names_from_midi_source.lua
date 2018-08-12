-- Try to find the <X 0 0 0 0 1 INSTRUMENTNAME info in first midi item in each selected track,
-- and use the INSTRUMENTNAME for the track

function println(msg)
  reaper.ShowConsoleMsg(msg .. "\n")
end

local numSelectedTracks = reaper.CountSelectedTracks(0)
for t = 0,numSelectedTracks-1 do
  local track = reaper.GetTrack(0, t)
  local numItems = reaper.CountTrackMediaItems(track)
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
        
        -- name may be hidden in here...
        if textsyxevtcnt > 0 then
          println("  Text event 0:")
          local idx = 0 -- just the first one for the instrument name
          --for idx = 0,textsyxevtcnt do
            local retval, selected, muted, ppqpos, type, msg = reaper.MIDI_GetTextSysexEvt(take, idx)
            println("    type: " .. type)
            println("    msg:  " .. msg)
          --end
          if idx == 0 then
            local newTrackName = msg
            local retval, _ = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", newTrackName, true)
          end
        end
      end
    end
  end
end
