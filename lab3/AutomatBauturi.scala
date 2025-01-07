import chisel3._
import chisel3.util._

class AutomatBauturi extends Module {
  val io = IO(new Bundle {
    val reset_input    = Input(Bool())
    val leu1           = Input(Bool())
    val lei5           = Input(Bool())
    val lei10          = Input(Bool())
    val cerere_produs  = Input(UInt(4.W))
    val cerere_rest    = Input(Bool())

    val produs         = Output(UInt(4.W))
    val leu1_rest      = Output(Bool())
    val lei5_rest      = Output(Bool())
    val refuza_bani    = Output(Bool())
  })

  val start :: acc_bani :: da_produs :: da_rest :: Nil = Enum(4)
  val stare = RegInit(start)

  val total_bani    = RegInit(0.U(4.W))
  val cereri_produs = RegInit(0.U(2.W))
  val cost_mem      = RegInit(0.U(4.W))

  val produs_reg      = RegInit(0.U(4.W))
  val leu1_rest_reg   = RegInit(false.B)
  val lei5_rest_reg   = RegInit(false.B)
  val refuza_bani_reg = RegInit(false.B)

  io.produs      := produs_reg
  io.leu1_rest   := leu1_rest_reg
  io.lei5_rest   := lei5_rest_reg
  io.refuza_bani := refuza_bani_reg

  when (io.reset_input) {
    stare          := start
    total_bani     := 0.U
    cereri_produs  := 0.U
    cost_mem       := 0.U

    produs_reg     := 0.U
    leu1_rest_reg  := false.B
    lei5_rest_reg  := false.B
    refuza_bani_reg:= false.B
  } .otherwise {
    produs_reg      := 0.U
    leu1_rest_reg   := false.B
    lei5_rest_reg   := false.B
    refuza_bani_reg := false.B

    switch (stare) {
      is (start) {
        total_bani    := 0.U
        cost_mem      := 0.U

        when (io.leu1) {
          total_bani := 1.U
          stare      := acc_bani
        } .elsewhen (io.lei5) {
          total_bani := 5.U
          stare      := acc_bani
        } .elsewhen (io.lei10) {
          total_bani := 10.U
          stare      := acc_bani
        } .otherwise {
          stare := start
        }
      }

      is (acc_bani) {
        when (io.leu1) {
          when (total_bani < 10.U) {
            when ((total_bani + 1.U) > 10.U) {
              refuza_bani_reg := true.B
            } .otherwise {
              total_bani := total_bani + 1.U
            }
          }
        } .elsewhen (io.lei5) {
          when (total_bani < 10.U) {
            when ((total_bani + 5.U) > 10.U) {
              refuza_bani_reg := true.B
            } .otherwise {
              total_bani := total_bani + 5.U
            }
          }
        } .elsewhen (io.lei10) {
          refuza_bani_reg := true.B
        }

        when (io.cerere_produs > 0.U) {
          when (total_bani >= io.cerere_produs) {
            cost_mem := io.cerere_produs
            stare    := da_produs
          } .otherwise {
            stare := acc_bani
          }
        } .elsewhen (io.cerere_rest) {
          when (total_bani > 0.U) {
            stare := da_rest
          } .otherwise {
            stare := start
          }
        } .otherwise {
          stare := acc_bani
        }
      }

      is (da_produs) {
        cereri_produs := cereri_produs + 1.U

        when (cereri_produs >= 2.U) {
          stare := da_rest
        } .otherwise {
          produs_reg   := cost_mem
          total_bani   := total_bani - cost_mem
          stare        := acc_bani
        }
      }

      is (da_rest) {
        when (total_bani >= 5.U) {
          lei5_rest_reg  := true.B
          total_bani     := total_bani - 5.U
          stare          := da_rest
        } .elsewhen (total_bani > 0.U) {
          leu1_rest_reg  := true.B
          total_bani     := total_bani - 1.U
          stare          := da_rest
        } .otherwise {
          stare := start
        }
      }
    }
  }
}