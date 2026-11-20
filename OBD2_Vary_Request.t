variables {

  // =====================================================
  // TIMERS
  // =====================================================

  Timer fastTimer;
  Timer medTimer;
  Timer slowTimer;

  CanMessage reqMsg;

  // =====================================================
  // PID INDEXES
  // =====================================================

  int fastIndex = 0;
  int medIndex  = 0;
  int slowIndex = 0;

  // =====================================================
  // FAST PIDS (50 ms)
  // Driver dynamics
  // =====================================================

  byte fastPids[7] = {
    0x0C, // RPM
    0x0D, // Speed
    0x11, // Throttle
    0x04, // Engine Load
    0x10, // MAF
    0x45, // Relative Throttle
    0x44  // Commanded AFR
  };

  // =====================================================
  // MEDIUM PIDS (250 ms)
  // Temps / pressures
  // =====================================================

  byte medPids[10] = {
    0x05, // Coolant Temp
    0x0F, // Intake Temp
    0x0B, // MAP
    0x33, // Barometric Pressure
    0x46, // Ambient Temp
    0x2F, // Fuel Level
    0x42, // Module Voltage
    0x43, // Absolute Load
    0x5C, // Oil Temp
    0x5E  // Fuel Rate
  };

  // =====================================================
  // SLOW PIDS (2000 ms)
  // Diagnostic/static info
  // =====================================================

  byte slowPids[15] = {
    0x1F, // Runtime
    0x21, // Distance w/ MIL
    0x30, // Warmups Since Clear
    0x31, // Distance Since Clear
    0x51, // Fuel Type
    0x52, // Ethanol %
    0x5B, // Hybrid Battery
    0x5F, // Emissions Req
    0x62, // Driver Torque
    0x63, // Actual Torque
    0x67, // Extended Coolant Temp
    0x68, // Extended Intake Temp
    0x6D, // Friction Torque
    0x8E, // Friction %
    0xA6  // Odometer
  };

  int fastCount = 7;
  int medCount  = 10;
  int slowCount = 15;
}

// =====================================================
// INITIALIZATION
// =====================================================

on start {

  // Configure request frame
  reqMsg.id    = 0x7DF;
  reqMsg.dlc   = 8;
  reqMsg.flags = 0;

  // Start timers
  fastTimer.timeout = 50;
  medTimer.timeout  = 250;
  slowTimer.timeout = 2000;

  timerStart(fastTimer, FOREVER);
  timerStart(medTimer, FOREVER);
  timerStart(slowTimer, FOREVER);
}

// =====================================================
// HELPER FUNCTION
// =====================================================

void sendRequest(byte pid)
{
  reqMsg.data[0] = 0x02;
  reqMsg.data[1] = 0x01;
  reqMsg.data[2] = pid;

  reqMsg.data[3] = 0x00;
  reqMsg.data[4] = 0x00;
  reqMsg.data[5] = 0x00;
  reqMsg.data[6] = 0x00;
  reqMsg.data[7] = 0x00;

  canWrite(reqMsg);
}

// =====================================================
// FAST TIMER
// =====================================================

on Timer fastTimer {

  sendRequest(fastPids[fastIndex]);

  fastIndex++;

  if (fastIndex >= fastCount) {
    fastIndex = 0;
  }
}

// =====================================================
// MEDIUM TIMER
// =====================================================

on Timer medTimer {

  sendRequest(medPids[medIndex]);

  medIndex++;

  if (medIndex >= medCount) {
    medIndex = 0;
  }
}

// =====================================================
// SLOW TIMER
// =====================================================

on Timer slowTimer {

  sendRequest(slowPids[slowIndex]);

  slowIndex++;

  if (slowIndex >= slowCount) {
    slowIndex = 0;
  }
}