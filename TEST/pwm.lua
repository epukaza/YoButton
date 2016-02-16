PWM_TIMER = 6
PWM_PIN = 5
INTERVAL_MS = 3
step = 1
duty = 0
pwm.setup(PWM_PIN, 60, duty)

tmr.register(PWM_TIMER, INTERVAL_MS, tmr.ALARM_AUTO, function ()
  pwm.setduty(PWM_PIN, duty)
  duty = duty + step
  if duty > 1000 then
  print(duty)
end
  if duty >= 1023 then
    step = step * -1
  elseif duty < 0 then
    step = step * -1
  end
end)

tmr.start(PWM_TIMER)