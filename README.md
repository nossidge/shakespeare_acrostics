# Acrostic Shakespearean Sonnets

by Paul Thompson - nossidge@gmail.com

My [entry][0] for [NaNoGenMo][1] [2017][2].

[0]: https://github.com/NaNoGenMo/2017/issues/8
[1]: https://nanogenmo.github.io/
[2]: https://github.com/NaNoGenMo/2017


## Status

In progress.


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

The data will come from the [Open Source Shakespeare][3] database, adapted
for PostgreSQL by [Catherine Devlin][4].

[The Sonnets][5] will be used as the basis of the acrostics, and the actual
lines themselves will come from anywhere in any of the plays and poems.

[3]: http://www.opensourceshakespeare.org/downloads/
[4]: https://github.com/catherinedevlin/opensourceshakespeare
[5]: https://en.wikipedia.org/wiki/Shakespeare%27s_sonnets
