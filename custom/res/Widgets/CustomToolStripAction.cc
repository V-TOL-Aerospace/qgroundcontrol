/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#include "CustomToolStripAction.h"

CustomToolStripAction::CustomToolStripAction(QObject* parent)
    : QObject(parent)
{

}

void CustomToolStripAction::setEnabled(bool enabled)
{
    if (enabled != _enabled) {
        _enabled = enabled;
        emit enabledChanged(enabled);
    }
}

void CustomToolStripAction::setVisible(bool visible)
{
    if (visible != _visible) {
        _visible = visible;
        emit visibleChanged(visible);
    }

}

void CustomToolStripAction::setCheckable(bool checkable)
{
    if (checkable != _checkable) {
        _checkable = checkable;
        emit checkableChanged(checkable);
    }

}

void CustomToolStripAction::setChecked(bool checked)
{
    if (checked != _checked) {
        _checked = checked;
        emit checkedChanged(checked);
    }

}

void CustomToolStripAction::setShowAlternateIcon(bool showAlternateIcon)
{
    if (showAlternateIcon != _showAlternateIcon) {
        _showAlternateIcon = showAlternateIcon;
        emit showAlternateIconChanged(showAlternateIcon);
    }

}

void CustomToolStripAction::setText(const QString& text)
{
    if (text != _text) {
        _text = text;
        emit textChanged(text);
    }

}

void CustomToolStripAction::setIconSource(const QString& iconSource)
{
    if (iconSource != _iconSource) {
        _iconSource = iconSource;
        emit iconSourceChanged(iconSource);
    }

}

void CustomToolStripAction::setAlternateIconSource(const QString& alternateIconSource)
{
    if (alternateIconSource != _alternateIconSource) {
        _alternateIconSource = alternateIconSource;
        emit alternateIconSourceChanged(alternateIconSource);
    }
}

void CustomToolStripAction::setDropPanelComponent(QQmlComponent* dropPanelComponent)
{
    _dropPanelComponent = dropPanelComponent;
    emit dropPanelComponentChanged();
}

void CustomToolStripAction::setIconTrueColor(bool iconTrueColor)
{
    if (iconTrueColor != _iconTrueColor) {
        _iconTrueColor = iconTrueColor;
        emit iconTrueColorChanged(iconTrueColor);
    }
}

void CustomToolStripAction::setButtonColor(const QString& buttonColor)
{
    if (buttonColor != _buttonColor) {
        _buttonColor = buttonColor;
        emit buttonColorChanged(buttonColor);
    }
}

void CustomToolStripAction::setIconColor(const QString& iconColor)
{
    if (iconColor != _iconColor) {
        _iconColor = iconColor;
        emit iconColorChanged(iconColor);
    }
}

void CustomToolStripAction::setIsBlankButton(bool isBlankButton)
{
    if (isBlankButton != _isBlankButton) {
        _isBlankButton = isBlankButton;
        emit isBlankButtonChanged(isBlankButton);
    }
}