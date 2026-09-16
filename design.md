# Forgotten Combination — Game Design

## Purpose

This document is the design reference for **Forgotten Combination**, a Playdate narrative puzzle game about opening combination locks. It is written for a future developer deciding what to implement next, especially the first complete locker scenario.

The immediate goal is to build one satisfying lock-solving loop before adding the full campaign.

## Game premise

The player is a student who has received their locker combination but is missing one number. They must use the physical feel and sound of the Playdate crank to discover the missing number, then perform the correct combination sequence.

Opening the locker starts an escalating chain of requests: first from a bully, then a teacher, principal, mayor, senator, and finally the President. The apparent stakes grow absurdly higher, ending with the reveal that the President needed a lock opened to retrieve lunch.

## Player objective

Unlock the current lock.

Each lock has a three-number combination. Some numbers are provided by the lock owner; the player must discover the rest from clues embedded in the lock's behavior. The player then executes the combination correctly to advance the story.

There is no score attack or time penalty in the intended first version. Failure costs only the current attempt: the player must clear the lock and try the sequence again.

## Core player loop

1. A character explains why their lock needs opening and supplies any known combination numbers.
2. The player clears the lock with three uninterrupted clockwise revolutions.
3. The player turns the dial and observes clues to discover the next unknown number.
4. The player stops at the target and reverses direction as required by the combination.
5. If the player turns past a found target or reverses incorrectly, the attempt resets.
6. The player keeps any narrative information and clues learned, clears the lock again, and retries.
7. Unlocking the lock advances the narrative to the next owner and puzzle.

The desired feeling is not punishment. An unsuccessful attempt should feel like useful investigation: the player learned something and can make a better attempt next time.

## Combination rules

The baseline lock follows a conventional three-number pattern:

1. Clear the lock with three clockwise rotations.
2. Turn clockwise to the first number.
3. Reverse and turn counterclockwise to the second number.
4. Reverse and turn clockwise to the third number.
5. The lock opens.

Once the player has moved beyond the target's one-detent grace window, they must reset and clear the lock before retrying. This makes stopping and reversing at a discovered clue meaningful while allowing a small amount of physical wiggle room.

## Input vocabulary and feedback

The player has a small, consistent toolkit for every lock. Difficulty comes from how clearly the lock exposes clues, not from continually adding controls.

| Input | Action |
| --- | --- |
| Crank | Move through the dial's discrete 9-degree detents. |
| D-pad Left / Right | Select one of three ordered scratchpad slots. |
| A | Record the current dial number in the selected scratchpad slot. |
| D-pad Up | Toggle visual-inspection mode. |
| D-pad Down | Toggle listening mode. |
| Hold B while turning | Apply tension and amplify clues. |
| Tap B while stationary | Attempt to open the lock. |

Every detent advances the knob animation and plays a normal click. The current dial number and clearing progress are visible.

### Scratchpad

The scratchpad contains three ordered slots: first, second, and third combination number. It is a player note-taking aid, not a shortcut for entering the code.

- Story-provided numbers begin prefilled in their correct slot.
- The player selects a writable, non-supplied slot with Left and Right. Selection does not wrap at either end.
- Pressing A records the current dial number in the selected slot, replacing any previous note.
- Scratchpad notes survive failed attempts.
- The actual lock still opens only when the player physically performs the correct crank sequence and attempts to open it.

An empty slot is displayed as `--`. Story-provided numbers have a solid white background and box, which distinguishes them from player notes and shows that they cannot be selected. The game does not reject incorrect notes; they are the player's hypotheses.

### Visual-inspection mode

Pressing Up toggles a zoomed inspection view of the top of the dial. This view makes visual mechanical tells, such as a sticky detent or a moving lock pin, easier to notice. Pressing Up again returns to the normal view. Inspection and listening mode are mutually exclusive; entering one exits the other.

### Listening mode

Pressing Down toggles listening mode. The visuals dim to reduce distraction, ordinary detent clicks are muffled, and the relevant target click becomes more pronounced. Pressing Down again returns to normal mode.

### Tension and opening

Holding B while rotating applies tension. Tension raises clue intensity. Early locks should remain solvable without tension; later locks may require it for a clue to become clear.

Tapping B while the dial is stationary attempts to open the lock. A B press becomes a tension gesture if the player moves through at least one detent while holding it. Releasing B after a tension gesture does not attempt an opening.

### Baseline discovery clue

For the first locks, passing the currently relevant unknown number produces a distinctive click sound and a small sticky delay in dial rotation. The player learns the number from where that clue occurs on the dial. The same clue has both audio and visual forms, so the puzzle remains solvable through inspection without relying solely on sound.

The player has a one-detent grace window after a target clue. They may move one additional detent in the same direction before reversing; a second additional detent resets the attempt.

## Knowledge and attempt state

The design should keep these concepts separate:

| Kind of state | Examples | Reset after a failed attempt? |
| --- | --- | --- |
| Lock definition | Actual code, clue rules, supplied numbers | No |
| Player knowledge | Numbers supplied by a character; scratchpad notes; clues the player has learned | No |
| Attempt state | Clearing progress, current direction, current code position | Yes |

This distinction supports the intended puzzle loop. The lock can reset without erasing what the player has learned.

## Story campaign

| Chapter | Lock owner | Numbers initially known | Purpose |
| --- | --- | ---: | --- |
| 1 | Player | 2 of 3 | Tutorial: special click, scratchpad, and the basic lock sequence. |
| 2 | School bully | 1 of 3 | Discover two numbers with clear baseline clues. |
| 3 | Teacher | 0 of 3 | Apply the full baseline toolkit independently. |
| 4 | Principal | TBD | Clues become subtle; inspection and listening are useful. |
| 5 | Mayor | TBD | Clues are weaker, but tension makes them clear. |
| 6 | Senator | TBD | Require careful use of the established toolkit. |
| 7 | President | TBD | Final lock: tension is required; it protects the President's lunch. |

The escalating authority figures are intentional comedy. Each request should sound more serious than the last while preserving the mundane act of helping someone open a locker or container.

## Clue intensity and difficulty

The game stays short by keeping its toolkit fixed. It should not introduce a separate new mechanic for every story chapter. Instead, later locks reduce the intensity of the familiar audio and visual signals.

Each lock has tunable base clue strengths and bonuses:

```text
base visual intensity
base audio intensity
tension bonus
inspection bonus
listening bonus
```

Effective clue strength is calculated by the active mode:

| State | Visual intensity | Audio intensity |
| --- | --- | --- |
| Normal | Base visual + tension bonus while B is held | Base audio + tension bonus while B is held |
| Inspection | Base visual + tension bonus while B is held + inspection bonus | Base audio |
| Listening | Base visual | Base audio + tension bonus while B is held + listening bonus |

Visual intensity controls the size and duration of the target's sticky delay or pin movement. Audio intensity controls the volume, pitch, and duration difference between normal and target clicks.

- Early locks have obvious target clicks and visual tells; tension is optional.
- Mid-game locks have subtler baseline cues; inspection or listening makes them easier to distinguish.
- Late locks have cues that become reliably readable only while applying tension.
- The final lock requires tension, but a player may use either listening or inspection as their primary clue channel.

The game must not make both channels merely barely perceptible. When the player uses the appropriate mode and tension, the intended clue should become clear enough to act on confidently.

### Sticky detents

A target briefly delays dial rotation and can show a small pin movement. Inspection mode makes the delay easier to read; tension makes it stronger. The exact art treatment remains to be decided.

## Narrative, tutorial, and screen flow

The intended high-level flow is:

```text
Opening / tutorial
    -> character dialogue and known-number briefing
    -> lock puzzle
    -> unlock result
    -> next character dialogue
    -> next lock
    -> ending
```

### Narrative dialogue scenes

Transitions between locks use a dialogue scene with two fixed regions:

- The right third of the display contains a sprite or illustration of the speaking character.
- The left two-thirds contains a speech bubble or text box for narrative, instruction, and dialogue.

Dialogue is displayed as a sequence of short pages in a conventional game text-box flow. Each page needs a visible continuation prompt. Character portraits and dialogue text are content that can be added per story beat.

### Tutorial overlays

Tutorial text overlays the active lock screen. It presents only enough instruction to start the player experimenting; it does not attempt to teach every mechanic at once.

Draft opening-locker tutorial text:

> Aw man, I lost the last digit to my locker combination. I've gotta figure this out. Maybe if I look closely with Up and listen closely with Down, I'll be able to figure out what the last number is. When I think I have it, I'll open the locker with B.

Draft bully-locker prompt:

> I wonder if I hold down the open button B if that will help me figure out the missing numbers...

### Unlock transition

When the player successfully opens a lock:

```text
Lock screen
    -> transition to white
    -> full-screen illustration of the opened locker, box, or container
    -> next dialogue scene
```

Each story lock therefore needs an associated open-container illustration. The white transition separates the mechanical puzzle from the narrative payoff.

## First playable milestone

Implement the player's locker as a complete vertical slice:

1. Show a short tutorial briefing that provides two of the three numbers.
2. Prefill the two known values in the scratchpad and leave the third slot empty.
3. Let the player select a scratchpad slot and record the current dial number with A.
4. Start the lock with the third number unknown and provide a clear audio and visual target clue.
5. Preserve supplied information and scratchpad notes across failed attempts.
6. Include the inspection, listening, and tension controls, even if the first lock does not require all of them.
7. Show the opening tutorial overlay with the draft tutorial text.
8. On success, transition to a white screen, then show an open-locker illustration and the bully's request in a dialogue scene.
9. Allow starting the bully lock or end the prototype after the success scene.

Completing this milestone proves the narrative-puzzle loop, not just the lock mechanic.

## Decisions still needed

### Scratchpad and controls

- Should a B tap have a maximum duration before it stops counting as an opening attempt?
- Which input advances a dialogue page, and does another input fast-forward or skip text?

### Failure behavior

- Does a wrong direction always reset immediately, including during the one-detent grace window?

### Clue system

- Does the clue activate only for the next required combination number?
- What clue-strength profile belongs to each lock owner?
- What exact normal-click and target-click sounds convey increasing audio intensity?
- What exact pin or dial art conveys increasing visual intensity?

### Narrative

- What does each character say before and after their lock?
- What physical object does each later lock protect?
- Does the story take place entirely at school before expanding to civic and national locations, or is the escalation deliberately dreamlike?
- What artwork is needed for each character portrait and open-container result?

### Completion and accessibility

- Can the player replay completed locks or revisit dialogue?
- Does the game need save/resume support?
- What accommodations are needed for players who cannot distinguish the clue sounds easily?

## Design constraints

- The crank is the primary input and should remain central to every lock.
- Failure should create curiosity and learning, not frustration.
- Each new mechanic must have a clear signal and a reliable interpretation.
- Narrative escalation should support the comedy without obscuring the puzzle objective.
- The game should favor a small number of polished locks over many underexplained variations.
