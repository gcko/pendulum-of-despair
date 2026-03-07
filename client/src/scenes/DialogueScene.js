/**
 * scenes/DialogueScene.js
 * FF6-style dialogue system with typewriter effect.
 *
 * Renders a dark-blue dialogue box with:
 * - Speaker name portrait area (left side)
 * - Typewriter text animation
 * - Multiple pages (advance with Space/Enter/Click)
 * - Optional choice branches
 *
 * Launch via: this.scene.launch('DialogueScene', { dialogue, onClose })
 */

const BOX_PADDING   = 16;
const CHAR_DELAY_MS = 30; // ms per character in typewriter effect

export default class DialogueScene extends Phaser.Scene {
  constructor() {
    super({ key: 'DialogueScene' });
  }

  init(data) {
    this._dialogue  = data.dialogue;   // { speaker, pages, choices, next }
    this._onClose   = data.onClose || (() => {});
    this._allDialogues = data.allDialogues || null; // For branching
    this._pageIndex = 0;
    this._charIndex = 0;
    this._typing    = false;
    this._done      = false;
    this._displayText = '';
  }

  create() {
    const { width, height } = this.cameras.main;

    // ── Backdrop (clicking anywhere advances) ─────────────────────────────────
    this._backdrop = this.add.rectangle(0, 0, width, height, 0x000000, 0.01)
      .setOrigin(0, 0).setInteractive();
    this._backdrop.on('pointerdown', () => this._advance());

    // ── Dialogue box ──────────────────────────────────────────────────────────
    const boxH  = 120;
    const boxY  = height - boxH - 8;
    const boxW  = width - 16;

    this._boxBg = this.add.graphics();
    this._drawBox(8, boxY, boxW, boxH);

    // ── Speaker name ──────────────────────────────────────────────────────────
    const speakerName = this._dialogue.speaker || '';
    if (speakerName) {
      // Name badge above left of box
      const nameBg = this.add.graphics();
      nameBg.fillStyle(0x000044, 1);
      nameBg.fillRoundedRect(14, boxY - 22, speakerName.length * 8 + 16, 22, { tl: 4, tr: 4, bl: 0, br: 0 });
      nameBg.lineStyle(2, 0x5577cc, 1);
      nameBg.strokeRoundedRect(14, boxY - 22, speakerName.length * 8 + 16, 22, { tl: 4, tr: 4, bl: 0, br: 0 });

      this.add.text(22, boxY - 14, speakerName, {
        fontFamily: '"Press Start 2P", monospace',
        fontSize:   '8px',
        color:      '#aaddff',
      });
    }

    // ── Dialogue text ─────────────────────────────────────────────────────────
    this._textObj = this.add.text(
      8 + BOX_PADDING,
      boxY + BOX_PADDING,
      '',
      {
        fontFamily:  '"Press Start 2P", monospace',
        fontSize:    '9px',
        color:       '#ffffff',
        wordWrap:    { width: boxW - BOX_PADDING * 2 - 16 },
        lineSpacing: 6,
      }
    );

    // ── "More" indicator (blinking arrow at bottom-right of box) ─────────────
    this._moreArrow = this.add.text(
      8 + boxW - BOX_PADDING,
      boxY + boxH - BOX_PADDING,
      '▼',
      {
        fontFamily: '"Press Start 2P", monospace',
        fontSize:   '10px',
        color:      '#aaccff',
      }
    ).setOrigin(1, 1).setAlpha(0);

    this.tweens.add({ targets: this._moreArrow, alpha: 1, duration: 400, yoyo: true, repeat: -1 });

    // ── Choice buttons (built when choices are shown) ─────────────────────────
    this._choiceObjs = [];

    // ── Keyboard: Space/Enter to advance ─────────────────────────────────────
    this._advanceKey = this.input.keyboard.addKey('SPACE');
    this._enterKey   = this.input.keyboard.addKey('ENTER');
    this._advanceKey.on('down', () => this._advance());
    this._enterKey.on('down',   () => this._advance());

    // ── Start typing first page ───────────────────────────────────────────────
    this._startTyping();
  }

  update(_, delta) {
    if (!this._typing) return;

    this._typeTimer = (this._typeTimer || 0) + delta;
    const charsToAdd = Math.floor(this._typeTimer / CHAR_DELAY_MS);
    if (charsToAdd === 0) return;

    this._typeTimer -= charsToAdd * CHAR_DELAY_MS;
    const fullText = this._currentPage();
    const nextIndex = Math.min(this._charIndex + charsToAdd, fullText.length);
    this._charIndex = nextIndex;
    this._textObj.setText(fullText.slice(0, nextIndex));

    if (this._charIndex >= fullText.length) {
      this._typing = false;
      this._moreArrow.setAlpha(1);
    }
  }

  // ── Internal helpers ──────────────────────────────────────────────────────

  _currentPage() {
    return (this._dialogue.pages || [])[this._pageIndex] || '';
  }

  _startTyping() {
    this._charIndex  = 0;
    this._typing     = true;
    this._typeTimer  = 0;
    this._textObj.setText('');
    this._moreArrow.setAlpha(0);
    this._clearChoices();
  }

  /** Advance: skip typewriter OR go to next page OR show choices OR close. */
  _advance() {
    if (this._typing) {
      // Skip to end of current page instantly
      this._charIndex = this._currentPage().length;
      this._textObj.setText(this._currentPage());
      this._typing = false;
      this._moreArrow.setAlpha(1);
      return;
    }

    const pages = this._dialogue.pages || [];
    const nextPage = this._pageIndex + 1;

    if (nextPage < pages.length) {
      this._pageIndex = nextPage;
      this._startTyping();
      return;
    }

    // All pages shown — show choices, chain to next dialogue, or close
    if (this._dialogue.choices && this._dialogue.choices.length > 0) {
      this._showChoices();
    } else if (this._dialogue.next && this._allDialogues) {
      const nextDial = this._allDialogues.find((d) => d.id === this._dialogue.next);
      if (nextDial) {
        this.scene.restart({ dialogue: nextDial, onClose: this._onClose, allDialogues: this._allDialogues });
      } else {
        this._close();
      }
    } else {
      this._close();
    }
  }

  _showChoices() {
    this._moreArrow.setAlpha(0);
    this._clearChoices();

    const { width, height } = this.cameras.main;
    const boxH  = 120;
    const boxY  = height - boxH - 8;
    const startY = boxY + 20;

    this._dialogue.choices.forEach((choice, i) => {
      const y = startY + i * 22;
      const marker = this.add.text(
        8 + BOX_PADDING + 4, y,
        i === 0 ? '▶' : '  ',
        { fontFamily: '"Press Start 2P", monospace', fontSize: '8px', color: '#aaccff' }
      );
      const txt = this.add.text(
        8 + BOX_PADDING + 18, y,
        choice.text,
        { fontFamily: '"Press Start 2P", monospace', fontSize: '8px', color: '#ffffff' }
      ).setInteractive({ useHandCursor: true });

      txt.on('pointerover', () => {
        this._choiceObjs.forEach((o) => o.marker.setText('  '));
        marker.setText('▶');
        txt.setColor('#ffffaa');
        this._selectedChoice = i;
      });
      txt.on('pointerout',  () => { txt.setColor('#ffffff'); });
      txt.on('pointerdown', () => this._selectChoice(i));

      this._choiceObjs.push({ marker, txt });
    });

    this._selectedChoice = 0;

    // Allow keyboard navigation of choices
    const upKey   = this.input.keyboard.addKey('UP');
    const downKey = this.input.keyboard.addKey('DOWN');
    upKey.on('down', () => {
      this._selectedChoice = Math.max(0, this._selectedChoice - 1);
      this._updateChoiceCursors();
    });
    downKey.on('down', () => {
      this._selectedChoice = Math.min(this._dialogue.choices.length - 1, this._selectedChoice + 1);
      this._updateChoiceCursors();
    });
    this._enterKey.removeAllListeners('down');
    this._advanceKey.removeAllListeners('down');
    this._enterKey.on('down', () => this._selectChoice(this._selectedChoice));
    this._advanceKey.on('down', () => this._selectChoice(this._selectedChoice));
  }

  _updateChoiceCursors() {
    this._choiceObjs.forEach((o, i) => {
      o.marker.setText(i === this._selectedChoice ? '▶' : '  ');
    });
  }

  _selectChoice(index) {
    const choice = this._dialogue.choices[index];
    if (!choice) return;

    // Handle special actions
    if (choice.action === 'save') {
      this.events.emit('action_save');
    } else if (choice.action === 'rest') {
      this.events.emit('action_rest');
    }

    if (choice.next && this._allDialogues) {
      const nextDial = this._allDialogues.find((d) => d.id === choice.next);
      if (nextDial) {
        this.scene.restart({ dialogue: nextDial, onClose: this._onClose, allDialogues: this._allDialogues });
        return;
      }
    }

    this._close();
  }

  _clearChoices() {
    for (const { marker, txt } of this._choiceObjs) {
      marker.destroy();
      txt.destroy();
    }
    this._choiceObjs = [];
  }

  _close() {
    this._onClose();
  }

  _drawBox(x, y, w, h) {
    this._boxBg.fillStyle(0x000033, 0.92);
    this._boxBg.fillRoundedRect(x, y, w, h, 6);
    this._boxBg.lineStyle(2, 0x5577cc, 1);
    this._boxBg.strokeRoundedRect(x, y, w, h, 6);
    this._boxBg.lineStyle(1, 0x8899dd, 0.5);
    this._boxBg.strokeRoundedRect(x + 2, y + 2, w - 4, h - 4, 5);
  }
}
