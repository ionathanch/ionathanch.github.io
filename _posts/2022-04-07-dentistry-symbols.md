---
layout: post
title: "U+23BE..U+23CC DENTISTRY NOTATION SYMBOLS"
excerpt_separator: "<!--more-->"
tags:
  - Unicode
---

The Unicode Standard has its fair share of mysterious and sometimes unexplained characters.
The [story of the Farsi symbol](http://archives.miloush.net/michkap/archive/2005/01/29/363208.html)
(U+262B ☫ FARSI SYMBOL) is one of the more well-known ones.
Many blocks, especially the "miscellaneous" blocks, have smatterings of rather arbitrary character sets
grouped together only by history.
One such block is Miscellaneous Technical, which contains completely unrelated groups of characters,
including keyboard symbols, APL symbols, electrotechnical symbols, UI symbols, drafting symbols,
and of particular interest in this blog post, dentistry notation symbols.
Here they are, all 15 of them:

```
⎾⎿⏀⏁⏂⏃⏄⏅⏆⏇⏈⏉⏊⏋⏌
```

The first two and last two are part of [Palmer notation](https://en.wikipedia.org/wiki/Palmer_notation)
for denoting human teeth by their position.
What are the rest for?

<!--more-->

The Unicode Standard, [Section 22.7 Technical Symbols](https://www.unicode.org/versions/Unicode14.0.0/ch22.pdf#G38022),
doesn't have much specific to say about the matter.

> **Dental Symbols.** The set of symbols from U+23BE to U+23CC form a set of symbols from
JIS X 0213 for use in dental notation.

Looking at the [Miscellaneous Technical code chart](https://www.unicode.org/charts/PDF/U2300.pdf),
their names describe the appearance of the symbols but not so much their function.

```
23C0 ⏀ DENTISTRY SYMBOL LIGHT VERTICAL WITH CIRCLE
23C1 ⏁ DENTISTRY SYMBOL LIGHT DOWN AND HORIZONTAL WITH CIRCLE
23C2 ⏂ DENTISTRY SYMBOL LIGHT UP AND HORIZONTAL WITH CIRCLE
23C3 ⏃ DENTISTRY SYMBOL LIGHT VERTICAL WITH TRIANGLE
23C4 ⏄ DENTISTRY SYMBOL LIGHT DOWN AND HORIZONTAL WITH TRIANGLE
23C5 ⏅ DENTISTRY SYMBOL LIGHT UP AND HORIZONTAL WITH TRIANGLE
23C6 ⏆ DENTISTRY SYMBOL LIGHT VERTICAL AND WAVE
23C7 ⏇ DENTISTRY SYMBOL LIGHT DOWN AND HORIZONTAL WITH WAVE
23C8 ⏈ DENTISTRY SYMBOL LIGHT UP AND HORIZONTAL WITH WAVE
23C9 ⏉ DENTISTRY SYMBOL LIGHT DOWN AND HORIZONTAL
23CA ⏊ DENTISTRY SYMBOL LIGHT UP AND HORIZONTAL
```

The [JIS X 0213](https://en.wikipedia.org/wiki/JIS_X_0213) is yet another character set encoding standard
and doesn't explain much either.
Any technical documents would probably be in Japanese, which I can't read.
Luckily, the Wikipedia page on Miscellaneous Technical keeps a pretty extensive
[historical record](https://en.wikipedia.org/wiki/Miscellaneous_Technical#History)
of how its characters were introduced into Unicode.
According to the table, the dentistry symbols were introduced in version 3.2 originating from a proposal in 1999.
Here's where we'll start our hunt for their meaning.

## History in Unicode 3.2

The dentistry symbols along with some circled digits were introduced in
[Addition of medical symbols and enclosed numbers](https://www.unicode.org/wg2/docs/n2093.pdf)
on 13 September 1999.
The document doesn't actually explain what the symbols mean.

{% include image.html
           img="/assets/images/dentistry-symbols/1.png"
           width="50%"
           title="Excerpt from 'Addition of medical symbols and enclosed numbers' showing the dentistry symbols, proposed codepoints, and their names."
           caption="There you have it. The earliest references to these symbols that I could find." %}

The Unicode Technical Committee has the same questions I do.
The [meeting minutes](https://www.unicode.org/consortium/utc-minutes/UTC-081-199910.html)
for a committee meeting over 26–29 October 1999 note:

> _Twenty Seven Dentist Characters_
<br/>
**Consensus 81-C5**: The circled characters will considered as part of a general mechanism as documented in  81-C4. Respond to the Shibano-san on the remaining proposed dentist symbols that we need evidence of usage. The UTC is not accepting any of the dentist symbols at this time. [L2/99-238]
<br/>
**Action Item 81-33 for Lisa Moore**: Inform Shibano-san that we are not accepting any of the dentist symbol characters, and provide our feedback.

And so in a [proposal comment](https://www.unicode.org/L2/L1999/99365.htm)
on 23 November 1999, Lisa Moore, chair of the Committee, writes:

> 6) Twenty Seven Dentist Characters. The UTC will consider the ten double circled numbers as part of the general mechanism to be defined in the future. See 4) above. The remaining seventeen dentist symbols were not accepted due to insufficient evidence of usage. Please provide documents with examples of usage, and explain if any of these characters are combining, or if any extend across other symbols to delineate quadrants of the jaw.

The 17 symbols refer to the 15 dentistry symbols along with U+29FA ⧺ DOUBLE PLUS and U+29FB ⧻ TRIPLE PLUS,
which are later encoded in Miscellaneous Mathematical Symbols-B.
In a [proposal revision](https://www.unicode.org/L2/L2000/00024.pdf) on 31 January 2000,
Professor Kohji Shibano, chairman of the JCS committee, writes:

> (c) Evidence of usage <br/>
You requested to submit evidence of usage for some characters. We are now preparing the requested document for the following characters with some explanation in English. This document will be sent to you as soon as possible.

{% include image.html
           img="/assets/images/dentistry-symbols/2.png"
           width="75%"
           title="(c) Evidence of usage. You requested to submit evidence of usage for some characters. We are now preparing the requested document for the following characters with some explanation in English. This document will be sent to you as soon as possible."
           caption="This explains nothing." %}

Finally, in [Rationale for non-Kanji characters proposed by JCS committee](https://www.unicode.org/L2/L2000/00098-n2195.pdf)
on 15 March 2000, the dentistry symbols are... "explained".

> (2) Dentist’s symbols <br/>
These symbols are used in dentistry when drawing XXX together with some BOX DRAWING characters. The proposal includes two types of characters; those used in single-line drawing and those in triple-line drawing.

{% include image.html
           img="/assets/images/dentistry-symbols/3.png"
           width="50%"
           title="Symbols to be used in single-line drawing: ⎾⎿⏁⏂⏄⏅⏇⏈⏉⏊⏋⏌
Symbols to be used in triple-line drawing: ⏀⏃⏆
Two figures follow: Example single line drawing, and Example triple-line drawing."
           caption="What does it mean???" %}

It makes sense that the lines are meant to be used with
[box-drawing characters](https://en.wikipedia.org/wiki/Box-drawing_character)
in dental notation to illustrate the teeth.
But what do the circle, the triangle, and the tilde mean?
The Wikipedia article on [dental notation](https://en.wikipedia.org/wiki/Dental_notation)
doesn't seem to use these symbols (and nor does the corresponding German article,
which is much more comprehensive).

The committees, on the other hand, seem satisfied with this explanation.
The [meeting minutes](https://www.unicode.org/L2/L2000/00234-n2203m.pdf)
for an ISO/IEC subcommittee meeting over 21–24 March 2000 note a comment
(Section 8.20, page 44) by Dr. Ken Whistler of Sybase, Inc.:

> ii) The Dental symbols are sufficiently explained - these are box-drawing characters overlaid in specific manner.

The [meeting minutes](https://www.unicode.org/L2/L2000/00115.htm)
for a Unicode Technical Committee meeting on 28 April 2000 read:

> **[83-M3] Motion**: Accept the twenty five characters documented in the report on the Beijing meeting, sections E 1, 2, 3, 5, 6, 7, 8, 9 [L2/00-108]:
<br/>
⚬ Double plus sign and triple plus sign
<br/>
⚬ 15 dentist symbols

So there aren't any more explanations we can expect to see from these documents.
Subsequent meeting minutes only discuss technical details.
From [19–22 September 2000](https://www.unicode.org/wg2/docs/n2253.pdf)
(Section 7.21, page 40):

> **Action Items**: Messrs. Michael Everson and Takayuki Sato - will provide better glyphs for the DENTIST Symbols (from document N2093). The amendment text is to be prepared by the editor.

From [9 March 2001](https://www.unicode.org/wg2/docs/n2328.pdf)
(Irish comments, page 5):

> **Table 63 (67) - Row 23: Miscellaneous Technical**
<br/>
The Japanese remarked in Athens that the glyphs for the dentistry symbols 23C0-23CC should fill a notional square. We have provided the editor with corrected glyphs.

And from [2–5 April 2001](https://www.unicode.org/wg2/docs/n2353.pdf),
more remarks on the shape of the characters (Section 7.1, page 21),
and the proposed character names are changed from DENTIST to DENTISTRY (Section 7.1, page 22):

> **Comment 14**: Shapes of JIS X0213 characters – Accepted.
<br/>
Japan will supply suitable fonts. Kana has to cover all existing Kana characters also. As to the Dentist symbols, glyphs do not seem to look square. We need to know why current glyphs are not acceptable. A single font is needed for a range.

> **SE6**: [...] Rename DENTIST to DENTISTRY symbols ... should it be DENTAL? Accept DENTISTRY.

On 27 March 2002, Unicode 3.2 is released.
The current blurb on dentistry symbols is added as part of the
[Unicode Standard Annex #28](https://www.unicode.org/reports/tr28/tr28-3.html#12_5_technical_symbols);
the new code points are highlighted in
[this code chart](https://www.unicode.org/charts/PDF/Unicode-3.2/U32-2300.pdf).

## Japanese Dentistry Notation

Just kidding. I wouldn't know where to start with that.