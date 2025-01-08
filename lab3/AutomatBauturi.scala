import chisel3._
import chisel3.util._

class AutomatBauturiIO extends Bundle {
  // intrari
  val clk            = Input(Clock())
  val reset          = Input(Bool())
  
  val leu1           = Input(Bool())
  val lei5           = Input(Bool())
  val lei10          = Input(Bool())

  val cerere_produs  = Input(UInt(4.W)) // 0..10
  val cerere_rest    = Input(Bool())

  // iesiri
  val produs         = Output(UInt(4.W)) // 0..10
  val leu1_rest      = Output(Bool())
  val lei5_rest      = Output(Bool())
  val refuza_bani    = Output(Bool())
}

class AutomatBauturi extends Module {
  val io = IO(new AutomatBauturiIO)

  // definire stari
  val sStart :: sAccBani  :: sDaProdus :: sDaRest :: Nil = Enum(4)


  val stateReg           = RegInit(sStart)
  val totalBaniReg       = RegInit(0.U(4.W))
  val cereriProdusReg    = RegInit(0.U(2.W))
  val costMemReg         = RegInit(0.U(4.W))

  val produsReg          = RegInit(0.U(4.W))
  val leu1RestReg        = RegInit(false.B)
  val lei5RestReg        = RegInit(false.B)
  val refuzaBaniReg      = RegInit(false.B)

  io.produs      := produsReg
  io.leu1_rest   := leu1RestReg
  io.lei5_rest   := lei5RestReg
  io.refuza_bani := refuzaBaniReg

  val nextState         = WireDefault(stateReg)
  val nextTotalBani     = WireDefault(totalBaniReg)
  val nextCereriProdus  = WireDefault(cereriProdusReg)
  val nextCostMem       = WireDefault(costMemReg)

  val nextProdusReg     = WireDefault(0.U(4.W))
  val nextLeu1RestReg   = WireDefault(false.B)
  val nextLei5RestReg   = WireDefault(false.B)
  val nextRefuzaBaniReg = WireDefault(false.B)


  switch(stateReg) {
    is(sStart) {
      // reseteaza iesirile
      nextTotalBani    := 0.U
      nextCostMem      := 0.U
      nextCereriProdus := 0.U

      when(io.leu1) {
        nextTotalBani := 1.U
        nextState     := sAccBani
      }.elsewhen(io.lei5) {
        nextTotalBani := 5.U
        nextState     := sAccBani
      }.elsewhen(io.lei10) {
        nextTotalBani := 10.U
        nextState     := sAccBani
      }.otherwise {
        nextState     := sStart
      }
    }

    is(sAccBani) {
      // reseteaza iesirile
      nextProdusReg      := 0.U
      nextLeu1RestReg    := false.B
      nextLei5RestReg    := false.B
      nextRefuzaBaniReg  := false.B

      // primeste bancnote
      when(io.leu1) {
        when(totalBaniReg + 1.U > 10.U) {
          nextRefuzaBaniReg := true.B
        }.otherwise {
          nextTotalBani := totalBaniReg + 1.U
        }
      }.elsewhen(io.lei5) {
        when(totalBaniReg + 5.U > 10.U) {
          nextRefuzaBaniReg := true.B
        }.otherwise {
          nextTotalBani := totalBaniReg + 5.U
        }
      }.elsewhen(io.lei10) {
        nextRefuzaBaniReg := true.B
      }

      // cerere de produs
      when(io.cerere_produs > 0.U) {
        when(totalBaniReg >= io.cerere_produs) {
          nextCostMem  := io.cerere_produs
          nextState    := sDaProdus
        }
      }.elsewhen(io.cerere_rest) {
        when(totalBaniReg > 0.U) {
          nextState := sDaRest
        }.otherwise {
          nextState := sStart
        }
      }
    }

    is(sDaProdus) {
      nextCereriProdus := cereriProdusReg + 1.U
      
      nextProdusReg    := 0.U
      nextLeu1RestReg  := false.B
      nextLei5RestReg  := false.B
      nextRefuzaBaniReg:= false.B

      when(cereriProdusReg >= 2.U) {
        nextState := sDaRest
      }.otherwise {
        nextProdusReg  := costMemReg
        nextTotalBani  := totalBaniReg - costMemReg
        nextState      := sAccBani
      }
    }

    is(sDaRest) {
      nextProdusReg     := 0.U
      nextRefuzaBaniReg := false.B

      when(totalBaniReg >= 5.U) {
        nextLei5RestReg := true.B
        nextLeu1RestReg := false.B
        nextTotalBani   := totalBaniReg - 5.U
        nextState       := sDaRest
      }.elsewhen(totalBaniReg > 0.U) {
        nextLei5RestReg := false.B
        nextLeu1RestReg := true.B
        nextTotalBani   := totalBaniReg - 1.U
        nextState       := sDaRest
      }.otherwise {
        nextLei5RestReg := false.B
        nextLeu1RestReg := false.B
        nextState       := sStart
      }
    }
  }

  // actualizare registri
  stateReg        := nextState
  totalBaniReg    := nextTotalBani
  cereriProdusReg := nextCereriProdus
  costMemReg      := nextCostMem

  produsReg       := nextProdusReg
  leu1RestReg     := nextLeu1RestReg
  lei5RestReg     := nextLei5RestReg
  refuzaBaniReg   := nextRefuzaBaniReg
}