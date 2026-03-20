pub type Route {
  Home
  Alerts
  Inputs
  Forms
  Buttons
}

pub type Model {
  Model(route: Route)
}

pub type Msg {
  OnRouteChange(Route)
}
