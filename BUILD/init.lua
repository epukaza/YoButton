DEBUG = true
SETUP = false
SETUP_TIMEOUT = 120000

STARTUP_DELAY_TIMER = 0
INTERRUPT_TIMER = 1
INDEX_TIMER = 2
SETUP_INACTIVITY_TIMER = 3
WIFI_WAIT_TIMER = 4
SUCCESS_SETUP_TIMER = 5

YO_RECIPIENT = nil

print("3 second startup delay using timer " .. STARTUP_DELAY_TIMER .. '...')
tmr.alarm(STARTUP_DELAY_TIMER, 3000, 0, function ()
    print("Starting.")

    function debugMsg(msg)
      print("Yo debug: " .. msg)
    end

    -- yo recipient file must exist
    yoRecipientExists = file.open('yorecipient.txt', 'r')
    if yoRecipientExists == nil then
      file.close()
      file.open('yorecipient.txt', 'w+')
      file.write('')
    else
      YO_RECIPIENT = file.read()
    end
    file.close()

    dofile("interrupt.lua")
  end)