echo -b 'Setting defaults for Dock...'

if type dockutil &>/dev/null; then

    dockutil --no-restart \
        --remove 'System Preferences' \
        --remove 'App Store' \
        --remove 'Maps' \
        --remove 'Notes' \
        --remove 'Photos' \
        --remove 'Messages' \
        --remove 'Contacts' \
        --remove 'Calendar' \
        --remove 'Reminders'\
        --remove 'FaceTime' \
        --remove 'Feedback Assistant' \
        --remove 'Siri' \
        --remove 'Launchpad' \
        --remove 'Numbers' \
        --remove 'Pages' \
        --remove 'Keynote' \
        --remove 'iTunes' \
        --remove 'iBooks' \
        &>/dev/null

fi
