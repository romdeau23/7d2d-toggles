7d2d toggles (AutoIt script)
############################

This is an `AutoIt <https://www.autoitscript.com/>`_ script for the game
`7 Days To Die <https://7daystodie.com/>`_.


How to use
**********

- download the latest .exe from `releases <https://github.com/romdeau23/7d2d-toggles/releases>`_

  - alternatively, you can download the `script <https://raw.githubusercontent.com/romdeau23/7d2d-toggles/master/7d2d-toggles.au3>`_
    (requires `AutoIt <https://www.autoitscript.com/>`_ to run)

- run it after or right before starting the game

  - the script automatically ends when the game is stopped


Features
********

.. NOTE::

   The script assumes default key mapping. You can edit the ``Global Const $KEYS``
   definition to use different `keys <https://github.com/310ken1/AutoItSciTEj/blob/master/language/au3/Include/WinAPIvkeysConstants.au3>`_.


Sprint toggle
=============

Quickly tapping ``SHIFT`` will hold down the ``SHIFT`` key for you.


Auto-run
========

Pressing ``+`` (on the numpad) makes the player (or vehicle) run forward until cancelled.


Auto-mine
=========

Pressing ``XBUTTON1`` (first extended mouse button) will hold down
the primary mouse button for you.


Known issues
************

- pressing ``TAB`` while auto-running will trigger the Steam overlay
