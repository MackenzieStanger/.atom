'use babel';

import CHeaderGeneratorView from './c-header-generator-view';
import { CompositeDisposable } from 'atom';

export default {

  cHeaderGeneratorView: null,
  modalPanel: null,
  subscriptions: null,

  activate(state) {
    this.cHeaderGeneratorView = new CHeaderGeneratorView(state.cHeaderGeneratorViewState);
    this.modalPanel = atom.workspace.addModalPanel({
      item: this.cHeaderGeneratorView.getElement(),
      visible: false
    });

    // Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    this.subscriptions = new CompositeDisposable();

    // Register command that toggles this view
    this.subscriptions.add(atom.commands.add('atom-workspace', {
      'c-header-generator:toggle': () => this.toggle()
    }));
  },

  deactivate() {
    this.modalPanel.destroy();
    this.subscriptions.dispose();
    this.cHeaderGeneratorView.destroy();
  },

  serialize() {
    return {
      cHeaderGeneratorViewState: this.cHeaderGeneratorView.serialize()
    };
  },

  toggle() {
	let editor
	if (editor = atom.workspace.getActiveTextEditor()) {
		let file = editor.buffer.file;
		if (file)
		{
			let filePath = file.path;
			console.log('Openned file is: ' + filePath);
			if (filePath.endsWith('.h'))
			{
				if (!editor.getText().includes("#ifndef"))
				{
					var macro = file.getBaseName();
					macro = macro.toUpperCase();
					macro = macro.replace('.H', '_H');
					editor.setCursorBufferPosition([0, 0]);
					editor.insertText('#ifndef ' + macro + '\n');
					editor.insertText('# define ' + macro + '\n\n\n\n#endif');
					editor.setCursorBufferPosition([3, 0]);
				}				
			}
			else
			{
				console.log('Openned file is not a c header file. Doing nothing.');
			}
		}
		else
		{
			console.log('No opened file, cowardly refusing to do anything.');
		}
	}
  }

};
