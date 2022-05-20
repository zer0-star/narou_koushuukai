suite "Main" {
  test "Greets Mint" {
    with Test.Html {
      <Works.Counter/>
      |> start()
      |> assertTextOf("p", "number: 0")
      |> triggerClick("button")
      |> assertTextOf("p", "number: 1")
    }
  }
}
