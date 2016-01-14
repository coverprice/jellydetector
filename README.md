# Jelly Detector

## What does it do?
Background agent that locks the screen when it detects that someone typed a specific word.

## Why does it exist?
People who leave their computer without locking the screen are exposed to a prank by their colleagues
to remind them that they should secure their PC more thoroughly.

The prankster will use the victim's machine to post to IRC or a Facebook status something like
"I love to eat Jello!" (the wording is often different, but the word 'jello' is always in there.
I don't know the origins).

To secure against this, the app examines the keyboard input stream and if it detects that someone
has typed the magic word, it immediately sends the computer to sleep, which also locks the screen
and locks the prankster out.

## How does it work?
It's pretty simple. The main loop hooks into the global keyDown event stream.

Internally, there is a state machine that looks for the next character in the magic word. (Repeat
consecutive letters are ignored). As the user types, the state machine will either progress towards the
end, or reset if the wrong character in sequence is pressed. If it reaches the end, the lock is
activated.

It supports pressing backspace, and also repeat characters (so someone can type 'jeeeellllooo'
and it will still activate).

## How do I install it?
Just run it. To monitor global key events, the app must be whitelisted in OSX's
"Settings > Security & Privacy > Accessibility" section. If it is not, the app will warn you about
this and open the dialog for you to add it. You'll need to restart the app after you do this.

## How do I get it to run on Login?
Navigate to "OSX Settings > Users & Groups > Login Items" and add the application.

## How can I change the word that it looks for?
Open JelloDetector/AppDelegate.m and edit the characters 'j', 'e', 'l', 'o', and make sure
MAXCHARS is the same number of characters.
