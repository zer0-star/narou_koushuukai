enum Page {
  NotFound
  Home
  Works
  Counter
}

store Application {
  state page : Page = Page::Home

  fun setPage(page : Page) : Promise(Never, Void) {
    next { page = page }
  }
}

routes {
  / {
    Application.setPage(Page::Home)
  }

  /works {
    Application.setPage(Page::Works)
  }

  /works/counter {
    Application.setPage(Page::Counter)
  }
  
  * {
    Application.setPage(Page::NotFound)
  }
}

component Main {
  connect Application exposing { page }

  get breadcrumbs {
    case (page) {
      Page::Home => [
        {"", <{ "Home" }>}
      ]

      Page::Works => [
        {"/", <{ "Home" }>},
        {"", <{ "Works" }>}
      ]

      Page::Counter => [
        {"/", <{ "Home" }>},
        {"/works", <{ "Works" }>},
        {"", <{ "Counter" }>}
      ]

      Page::NotFound => []
    }
  }

  get content {
    case (page) {
      Page::Home => <Home/>
      Page::Works => <Works/>
      Page::Counter => <Works.Counter/>
      Page::NotFound => <{ "404!" }>
    }
  }

  fun render : Html {
    <Ui.Theme.Root
      fontConfiguration={Ui:DEFAULT_FONT_CONFIGURATION}
      tokens={Ui:DEFAULT_TOKENS}>
      <Ui.Layout.Website
        header={
          <Ui.Header
            brand={
              <Ui.Brand
                size={Ui.Size::Em(1.2)}
                icon={Ui.Icons:DEVICE_DESKTOP}
                name="zer0-starの自己紹介"/>
            }
            items=[
              Ui.NavItem::Link(
                iconBefore = Ui.Icons:HOME,
                iconAfter = <></>,
                label = "Home",
                target = "",
                href = "/")
            ]/>
        }
        breadcrumbs={ <Ui.Breadcrumbs items={ breadcrumbs }/> }
        content={
          <Ui.Box>
             <{ content }>
          </Ui.Box>
        }
        footer={
          <Ui.Footer
            infos={<p>"Created by zer0-star"</p>}
            navitems=[
              {
                "Social", [
                  Ui.NavItem::Link(
                    iconBefore = <></>,
                    iconAfter = <></>,
                    href = "https://twitter.com/0x_zer0star",
                    target = "_blank",
                    label = "Twitter")
                ]
              }
            ]/>
        }/>
    </Ui.Theme.Root>
  }
}
