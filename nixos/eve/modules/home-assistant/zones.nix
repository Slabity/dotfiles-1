{ ... }: {
  services.home-assistant.config.homeassistant = {
    name = "Joerg's Home";
    latitude = "!secret home_latitude";
    longitude = "!secret home_longitude";
    elevation = "!secret home_elevation";
    unit_system = "metric";
    time_zone = "Europe/London";
  };
  services.home-assistant.config.zone = [{
    name = "Thalheim's Home";
    icon = "mdi:home";
    latitude = "!secret elternhaus_latitude";
    longitude = "!secret elternhaus_longitude";
    radius = "100";
  } {
    name = "Shannan's Home";
    icon = "mdi:human-female-girl";
    latitude = "!secret shannan_latitude";
    longitude = "!secret shannan_longitude";
    radius = "100";
  } {
    name = "Work of Shannan";
    icon = "mdi:office-building";
    latitude = "!secret shannan_work_latitude";
    longitude = "!secret shannan_work_longitude";
    radius = "100";
  } {
    name = "University";
    icon = "mdi:school";
    latitude = "!secret uni_latitude";
    longitude = "!secret uni_longitude";
    radius = "200";
  } {
    name = "Gym";
    icon = "mdi:weight-lifter";
    latitude = "!secret gym_latitude";
    longitude = "!secret gym_longitude";
    radius = "100";
  }];
}