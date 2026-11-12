{ lib, ... }:
{
  mapAttrNames = f: set: lib.mapAttrs' (name: value: lib.nameValuePair (f name) value) set;
}
