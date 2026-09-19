# Input

This folder is where you drop project materials for the bootstrap script (`../START-PLAYBOOK.md`) to read before bootstrapping the team.

## What to put here

Anything you have about the project, in any form. The wizard reads everything in this folder during Phase 4 of bootstrap.

- A concept doc, rough or polished (PDF, MD, TXT)
- A pitch deck (PDF or exported MD)
- A list of features you want to build
- A description of who the customers are
- Existing requirements, spec, or design notes
- Brand notes, voice samples, competitor analysis
- Any reference material that describes what you're building or who it serves

If you only have an idea in your head, that is fine. Skip this folder entirely. The wizard will offer a brainstorm dialogue to extract the concept from conversation, or install a vanilla team (all 17 personas as generic templates) you can customize later.

## What the wizard does with these materials

- Understands the project well enough to recommend which of the 17 personas matter most for it
- Drafts personalized versions of each chosen persona (voice, focus, what they own, what they decline) using insights from these materials
- Writes an initial `PROJECT-OVERVIEW.md` to `../knowledge/` summarizing the concept and the team decisions

## Privacy

This folder's contents are gitignored via `.gitignore` in this directory. Drop sensitive materials here without worrying that they will get committed back to the playbook source repo. Only `README.md` and `.gitignore` themselves are tracked.
