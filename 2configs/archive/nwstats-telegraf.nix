{ config, lib, pkgs, ... }:

{
  ptsd.nobbofin-autofetch.enable = true;
  ptsd.nwstats.enable = true;

  ptsd.nwtelegraf.inputs.http = [
    {
      name_override = "email";
      urls = [ "http://127.0.0.1:8000/mail" ];
      data_format = "json";
      tag_keys = [ "account" "folder" ];
    }
    {
      name_override = "todoist";
      urls = [ "http://127.0.0.1:8000/todoist" ];
      data_format = "json";
      tag_keys = [ "project" ];
    }
    {
      name_override = "nobbofin";
      urls = [ "http://127.0.0.1:8000/nobbofin" ];
      data_format = "json";
    }
  ];
}
