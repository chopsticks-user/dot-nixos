{ prev, ... }:
(prev.bottles.override {
  removeWarningPopup = true;
}).overrideAttrs
  (old: {
    passthru = (old.passthru or { }) // {
      removeWarningPopup = true;
      isWarningPopupRemoved = true;
    };

    meta = (old.meta or { }) // {
      description = "${old.meta.description or "Bottles"} (warning popup disabled)";
    };
  })
