#!/usr/bin/env bash
set -euo pipefail

GTK_THEME="Adwaita-dark"
ICON_THEME="Papirus-Dark"
CURSOR_THEME="Adwaita"

echo "Configuring GTK..."

mkdir -p ~/.config/gtk-3.0
cat >~/.config/gtk-3.0/settings.ini <<EOF
[Settings]
gtk-theme-name=$GTK_THEME
gtk-icon-theme-name=$ICON_THEME
gtk-cursor-theme-name=$CURSOR_THEME
gtk-application-prefer-dark-theme=1
EOF

mkdir -p ~/.config/gtk-4.0
cat >~/.config/gtk-4.0/settings.ini <<EOF
[Settings]
gtk-theme-name=$GTK_THEME
gtk-icon-theme-name=$ICON_THEME
gtk-cursor-theme-name=$CURSOR_THEME
gtk-application-prefer-dark-theme=1
EOF

mkdir -p ~/.config/gtk-2.0
cat >~/.config/gtk-2.0/gtkrc <<EOF
gtk-theme-name="$GTK_THEME"
gtk-icon-theme-name="$ICON_THEME"
gtk-cursor-theme-name="$CURSOR_THEME"
gtk-application-prefer-dark-theme=1
EOF

echo "Configuring GNOME dark preference..."

gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME"
gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME"
gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR_THEME"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"

echo "Configuring environment variables..."

mkdir -p ~/.config/environment.d

cat >~/.config/environment.d/theme.conf <<EOF
GTK_THEME=$GTK_THEME
GTK_ICON_THEME=$ICON_THEME
XDG_CURRENT_DESKTOP=sway
QT_QPA_PLATFORMTHEME=qt6ct
QT_STYLE_OVERRIDE=Adwaita-Dark
EOF

echo "Configuring Qt..."

mkdir -p ~/.config/qt5ct
cat >~/.config/qt5ct/qt5ct.conf <<EOF
[Appearance]
style=Adwaita-Dark
icon_theme=$ICON_THEME
EOF

mkdir -p ~/.config/qt6ct
cat >~/.config/qt6ct/qt6ct.conf <<EOF
[Appearance]
style=Adwaita-Dark
icon_theme=$ICON_THEME
EOF

echo "Adding shell fallback variables..."

if ! grep -q "QT_QPA_PLATFORMTHEME" ~/.profile 2>/dev/null; then
  cat >>~/.profile <<EOF

# Theme environment variables
export GTK_THEME=$GTK_THEME
export QT_QPA_PLATFORMTHEME=qt6ct
export QT_STYLE_OVERRIDE=Adwaita-Dark
export XDG_CURRENT_DESKTOP=sway
EOF
fi

echo "Applying Flatpak dark mode..."

if command -v flatpak >/dev/null; then
  flatpak override --user --env=GTK_THEME=$GTK_THEME
  flatpak override --user --env=ICON_THEME=$ICON_THEME
  flatpak override --user --env=QT_STYLE_OVERRIDE=Adwaita-Dark
fi

echo "Restarting portal services..."

systemctl --user restart xdg-desktop-portal.service || true

echo ""
echo "Dark mode fully configured."
echo "Restart Sway or log out to apply everything."
