import gleam/list
import gleam/option.{type Option, None, Some}
import saola/timeline

// ---------------------------------------------------------------------------
// Domain types
// ---------------------------------------------------------------------------

pub type Severity {
  Critical
  High
  Medium
  Low
}

pub type ThreatActor {
  ThreatActor(
    id: String,
    name: String,
    severity: Severity,
    country: String,
    ip: String,
    last_seen: String,
    connections: Int,
  )
}

pub type ThreatEdge {
  ThreatEdge(id: String, source: String, target: String, label: String)
}

pub type ThreatEvent {
  ThreatEvent(
    entity_id: String,
    time: String,
    title: String,
    description: String,
    variant: timeline.TimelineItemVariant,
  )
}

// ---------------------------------------------------------------------------
// Severity helpers
// ---------------------------------------------------------------------------

pub fn severity_label(s: Severity) -> String {
  case s {
    Critical -> "critical"
    High -> "high"
    Medium -> "medium"
    Low -> "low"
  }
}

pub fn severity_from_index(i: Int) -> Severity {
  case i % 4 {
    0 -> Critical
    1 -> High
    2 -> Medium
    _ -> Low
  }
}

pub fn all_severity_options() -> List(#(String, String)) {
  [
    #("critical", "Critical"),
    #("high", "High"),
    #("medium", "Medium"),
    #("low", "Low"),
  ]
}

// ---------------------------------------------------------------------------
// Static deterministic data
// ---------------------------------------------------------------------------

pub fn all_actors() -> List(ThreatActor) {
  [
    ThreatActor("t01", "APT-Phantom", Critical, "Russia", "185.220.101.42", "2026-05-18", 5),
    ThreatActor("t02", "DarkNebula", High, "China", "103.224.182.17", "2026-05-17", 4),
    ThreatActor("t03", "GhostRidge", High, "Iran", "91.108.4.121", "2026-05-17", 3),
    ThreatActor("t04", "SilentFang", Medium, "N.Korea", "175.45.176.0", "2026-05-16", 2),
    ThreatActor("t05", "IronVeil", Critical, "Russia", "194.165.16.77", "2026-05-18", 6),
    ThreatActor("t06", "BlueLotus", Medium, "China", "58.42.10.211", "2026-05-15", 2),
    ThreatActor("t07", "VoidCobra", High, "Iran", "5.79.66.25", "2026-05-17", 4),
    ThreatActor("t08", "RedAster", Low, "Unknown", "192.0.2.45", "2026-05-14", 1),
    ThreatActor("t09", "CrimsonDawn", Critical, "Russia", "45.142.212.100", "2026-05-18", 5),
    ThreatActor("t10", "SandStorm", High, "Iran", "188.209.52.14", "2026-05-16", 3),
    ThreatActor("t11", "FrostMoth", Medium, "China", "60.190.200.8", "2026-05-15", 2),
    ThreatActor("t12", "EmberPulse", Low, "Unknown", "203.0.113.88", "2026-05-13", 1),
    ThreatActor("t13", "NovaBreach", High, "N.Korea", "175.45.176.11", "2026-05-17", 3),
    ThreatActor("t14", "IceThorn", Medium, "Russia", "82.102.11.64", "2026-05-16", 2),
    ThreatActor("t15", "SolarFlare", Critical, "Unknown", "104.18.44.229", "2026-05-18", 7),
    ThreatActor("t16", "DuskRaven", Low, "China", "123.125.114.0", "2026-05-12", 1),
    ThreatActor("t17", "VolcanicKite", High, "Iran", "78.159.99.200", "2026-05-17", 4),
    ThreatActor("t18", "SteelThread", Medium, "Russia", "37.49.230.0", "2026-05-15", 2),
    ThreatActor("t19", "NightOwl", Critical, "N.Korea", "175.45.176.33", "2026-05-18", 5),
    ThreatActor("t20", "ClearWater", Low, "Unknown", "198.51.100.77", "2026-05-11", 1),
    ThreatActor("t21", "OrangeDrift", Medium, "China", "27.159.255.55", "2026-05-16", 2),
    ThreatActor("t22", "TangleSea", High, "Russia", "185.107.56.20", "2026-05-17", 3),
    ThreatActor("t23", "WildFrost", Low, "Unknown", "192.168.0.0", "2026-05-10", 1),
    ThreatActor("t24", "Ouroboros", Critical, "Unknown", "193.56.255.200", "2026-05-18", 8),
    ThreatActor("t25", "PurpleShard", Medium, "Iran", "46.36.199.188", "2026-05-14", 2),
    ThreatActor("t26", "MidnightHex", High, "China", "122.194.0.0", "2026-05-16", 3),
    ThreatActor("t27", "CopperGate", Low, "Russia", "91.234.254.0", "2026-05-09", 1),
    ThreatActor("t28", "BlazeLink", High, "Iran", "5.159.58.0", "2026-05-17", 4),
    ThreatActor("t29", "ZeroBloom", Critical, "N.Korea", "175.45.177.0", "2026-05-18", 6),
    ThreatActor("t30", "GrayEcho", Medium, "Unknown", "203.78.12.44", "2026-05-15", 2),
  ]
}

pub fn all_edges() -> List(ThreatEdge) {
  [
    ThreatEdge("e01", "t01", "t05", "coordinates"),
    ThreatEdge("e02", "t01", "t09", "shared-infra"),
    ThreatEdge("e03", "t01", "t22", "funds"),
    ThreatEdge("e04", "t05", "t09", "coordinates"),
    ThreatEdge("e05", "t05", "t15", "shares-tools"),
    ThreatEdge("e06", "t05", "t19", "recruits"),
    ThreatEdge("e07", "t09", "t29", "C2"),
    ThreatEdge("e08", "t02", "t06", "coordinates"),
    ThreatEdge("e09", "t02", "t11", "shared-infra"),
    ThreatEdge("e10", "t02", "t26", "funds"),
    ThreatEdge("e11", "t06", "t16", "phishing-kit"),
    ThreatEdge("e12", "t11", "t21", "lateral-move"),
    ThreatEdge("e13", "t03", "t07", "coordinates"),
    ThreatEdge("e14", "t03", "t10", "shared-infra"),
    ThreatEdge("e15", "t07", "t17", "exploits"),
    ThreatEdge("e16", "t07", "t28", "C2"),
    ThreatEdge("e17", "t10", "t25", "recruits"),
    ThreatEdge("e18", "t04", "t13", "coordinates"),
    ThreatEdge("e19", "t13", "t19", "shared-infra"),
    ThreatEdge("e20", "t19", "t29", "C2"),
    ThreatEdge("e21", "t15", "t24", "coordinates"),
    ThreatEdge("e22", "t24", "t29", "funds"),
    ThreatEdge("e23", "t24", "t15", "shared-infra"),
    ThreatEdge("e24", "t14", "t18", "exploits"),
    ThreatEdge("e25", "t14", "t22", "lateral-move"),
    ThreatEdge("e26", "t22", "t01", "C2"),
    ThreatEdge("e27", "t08", "t12", "phishing-kit"),
    ThreatEdge("e28", "t08", "t23", "shares-tools"),
    ThreatEdge("e29", "t12", "t20", "coordinates"),
    ThreatEdge("e30", "t23", "t27", "lateral-move"),
    ThreatEdge("e31", "t30", "t25", "exploits"),
    ThreatEdge("e32", "t30", "t21", "C2"),
    ThreatEdge("e33", "t26", "t16", "phishing-kit"),
    ThreatEdge("e34", "t17", "t10", "coordinates"),
    ThreatEdge("e35", "t28", "t03", "shared-infra"),
    ThreatEdge("e36", "t29", "t04", "funds"),
  ]
}

// ---------------------------------------------------------------------------
// Timeline events — 4–6 events per actor, derived from id
// ---------------------------------------------------------------------------

fn events_for_actor(id: String, name: String, severity: Severity) -> List(ThreatEvent) {
  let v = case severity {
    Critical -> timeline.Error
    High -> timeline.Warning
    Medium -> timeline.Default
    Low -> timeline.Success
  }
  [
    ThreatEvent(id, "2026-05-18 14:32", "C2 beacon detected", "Outbound connection to known C2 server", v),
    ThreatEvent(id, "2026-05-17 09:15", "Lateral movement", name <> " moved to adjacent subnet", timeline.Warning),
    ThreatEvent(id, "2026-05-16 22:08", "Credential harvest", "Extracted credentials from memory", v),
    ThreatEvent(id, "2026-05-15 11:44", "Initial access", "Spear-phishing email opened by target", timeline.Default),
    ThreatEvent(id, "2026-05-14 07:30", "Reconnaissance", "Port scan of DMZ observed", timeline.Success),
  ]
}

pub fn events_for(id: String) -> List(ThreatEvent) {
  case list.find(all_actors(), fn(a) { a.id == id }) {
    Error(_) -> []
    Ok(actor) -> events_for_actor(actor.id, actor.name, actor.severity)
  }
}

pub fn find_actor(id: String) -> Option(ThreatActor) {
  case list.find(all_actors(), fn(a) { a.id == id }) {
    Error(_) -> None
    Ok(actor) -> Some(actor)
  }
}
