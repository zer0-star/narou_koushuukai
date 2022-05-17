component Works.Counter {
  state count : Number = 0

  fun countUp (e : Html.Event) {
    next {
      count = count + 1
    }
  }

  fun countDown (e : Html.Event) {
    next {
      count = count - 1
    }
  }

  fun reset (e : Html.Event) {
    next {
      count = 0
    }
  }

  fun render : Html {
    <>
      <p> <{ "number: " + Number.toString(count) }> </p>
      <Ui.Container>
        <Ui.Button
          iconBefore={Ui.Icons:PLUS}
          label="count up"
          onClick={countUp}
          type="primary"/>

        <Ui.Button
          iconBefore={Ui.Icons:DASH}
          label="count down"
          onClick={countDown}
          type="primary"/>

        <Ui.Button
          iconBefore={Ui.Icons:TRASHCAN}
          label="reset"
          onClick={reset}
          type="warning"/>
      </Ui.Container>
    </>
  }
}