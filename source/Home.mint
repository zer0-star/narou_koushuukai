component Home {
  style card {
    max-width: 300px;
    margin-bottom: 5px;
  }

  fun render : Html {
    <>
      <div::card>
        <Ui.Card
          minWidth={Ui.Size::Px(300)}
          size={Ui.Size::Px(16)}
          bordered={true}
          target="_blank"
          href="https://twitter.com/0x_zer0star">
          <Ui.Card.Container
            content=<{ "traP所属 22B" }>
            thumbnail={@asset(../assets/images/icon.webp)}
            subtitle=<{ "@0x_zer0star" }>
            title=<{ "zer0-star" }>/>
        </Ui.Card>
      </div>
      <Ui.Row
        gap={Ui.Size::Px(12)}>
        <Ui.Box title=<{ "基本情報" }>>
          <ul>
            <li> "名前: zer0-star" </li>
            <li> "好きなもの: ゲーム" </li>
            <li> "趣味: インターネット" </li>
          </ul>
        </Ui.Box>
        <Ui.Box title=<{ "プログラミング言語" }>>
          <ul>
            <li> "Nim" </li>
            <li> "C++" </li>
            <li> "Haskell" </li>
          </ul>
        </Ui.Box>
      </Ui.Row>
      <p> "こんにちは！zer0-starです！インターネットに囚われています(たすけてください)" </p>
      <p> <a href="#works"> "作品一覧" </a> </p>
    </>
  }
}