# Acrostic Shakespearean Sonnets

by Paul Thompson - nossidge@gmail.com

My [entry][0] for [NaNoGenMo][1] [2017][2].

[0]: https://github.com/NaNoGenMo/2017/issues/8
[1]: https://nanogenmo.github.io/
[2]: https://github.com/NaNoGenMo/2017


## Status

Complete!

Full plaintext output can be found [here][6].

Total word count is 602,175.

On my machine it runs in about 70 seconds.

[6]: https://raw.githubusercontent.com/nossidge/shakespeare_acrostics/master/data/output_acrostics.txt


## Concept

Generate a set of sonnets that are acrostics, using every one of the letters
of each of Shakespeare's sonnets to start each line. Each line of the result
will be selected from elsewhere in the Shakespeare cannon, and they will use
the Shakespearean `ababcdcdefefgg` rhyming form.

The first 2 lines of the first sonnet are:

    From fairest creatures we desire increase,
    That thereby beauty's rose might never die,

So, removing non-alphas and splitting into 14-letter chunks, the first five
output poems will be acrostic sonnets on:

    fromfairestcre
    atureswedesire
    increasethatth
    erebybeautysro
    semightneverdi


## Corpus

The data comes from the [Open Source Shakespeare][3] database, adapted for
PostgreSQL by [Catherine Devlin][4].

[The Sonnets][5] is used as the basis of the acrostics, and the actual lines
themselves come from anywhere in any of the plays and poems.

[3]: http://www.opensourceshakespeare.org/downloads/
[4]: https://github.com/catherinedevlin/opensourceshakespeare
[5]: https://en.wikipedia.org/wiki/Shakespeare%27s_sonnets


### Amendment 1: Sonnet 146

*Sonnet 146* suffers from a typographical error in the original publication,
where the first two syllables of the second line are overwritten by words
from the preceding line. The affected line is recorded in the Open Source
Shakespeare database as:

    [         ] these rebel powers that thee array;

I wasn't sure what to do with this lacuna. Should I leave it as is, or should
I replace it with a more poetic alternative? There are a few well regarded
choices I could have selected, among them:

    Why feed'st
    Starv'd by
    Foiled by
    Fenced by
    Fool'd by
    Feeding
    Rebuke

I was sentimentally tempted to go with `Fool'd by`, as that's the replacement
used in my great-grandmother's *Complete Works*, but I went with `Why feed'st`
instead. The reason: it makes the envoi a four letter acrostic on
`love`, which really I think is just perfect.


### Amendment 2: Zounds!

My first attempt at generation failed. It left 16 sonnets that could not be
created using the correct letters with the correct rhymes. I investigated
this and discovered that it was the letter "Z" that was causing the issue.
There simply were not enough lines beginning with that letter in the corpus.

Examining the database, the only lines that start with "Z" are lines beginning
with `Zounds`. But because "zounds" is a contraction, there were other lines
in the data that begin instead with `'Zounds`.

My solution was to remove any leading apostrophes from lines that start with
it, so `'Zounds` becomes `Zounds`, and the acrostic regex can match `^[zZ]`.
Pretty simple change, and it fixed the issue completely.


## Replication / Forking

To install and run this code yourself, you'll need Ruby and PostgreSQL.


### Database setup

Download `shakespeare.sql` from [this repo][4].

[4]: https://github.com/catherinedevlin/opensourceshakespeare

Create a database using the instructions in the repo.

Save an environment variable 'DB_URL_SHAKESPEARE' with the database URL
in the below format:

    i.e.  postgres://user:password@server/database
    e.g.  postgres://Paul:swordfish@localhost/shakespeare


### Ruby setup

    git clone https://github.com/nossidge/shakespeare_acrostics.git
    cd shakespeare_acrostics
    bundle install

The generation code is in `lib/shakespeare_acrostics.rb`
