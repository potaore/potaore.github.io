var exports = exports;
if (!exports) exports = {};
const q_util = exports;
{
    const QLEN = 81;
    const ZEROS = `.abcdefghijklmnopqrsyuvwxyzABCDEFGHIJKLMNOPQRSYUVWXYZ!?,=-+*_^~/|%&"'()[]{}:;#$@0`;

    q_util.deflate = text => {
        let deflated = "";
        let zero_count = 0;
        for (let i = 0; i < QLEN; i++) {
            if (text.charAt(i).match(/[1-9]/)) {
                if (zero_count) deflated += ZEROS.charAt(zero_count - 1);
                zero_count = 0;
                deflated += text.charAt(i);
            } else {
                zero_count++;
            }
        }
        if (zero_count) deflated += ZEROS.charAt(zero_count - 1);
        return deflated;
    };

    q_util.inflate = deflated => {
        let text = "";
        for (let i = 0; i < deflated.length; i++) {
            const ch = deflated.charAt(i);
            if (ch.match(/[1-9]/)) {
                text += ch;
            } else {
                text += ".".repeat(ZEROS.indexOf(ch) + 1);
            }
        }
        return text;
    };

    q_util.to_json = text => {
        const q = [];
        let index = 0;
        for (let i = 0; i < 9; i++) {
            let row = [];
            for (let j = 0; j < 9; j++) {
                let ch = text.charAt(index);
                if (ch.match(/[1-9]/)) {
                    row.push(parseInt(ch));
                } else {
                    row.push(0);
                }
                index++;
            }
            q.push(row);
        }
        return q;
    };
}