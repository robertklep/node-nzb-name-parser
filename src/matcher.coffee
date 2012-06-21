# list of patterns matching common filenames
do ->
  XRegExp   = require('xregexp').XRegExp

  # list of common distributor patterns
  patterns  = [
    '''(?P<series>.*)\\.s(?P<season>\\d+)e(?P<episode>\\d+)\\.(?:ws|hdtv|720p).*?(?:-|(?:xvid|x264|sample)-)''',
    '''(?P<series>.*)\\.s(?P<season>\\d+)e(?P<episode>\\d+)\\.(?P<title>.*).*(?:ws|hdtv|720p).*?(?:-|(?:xvid|x264|sample)-)''',
    '''(?P<series>.*)\\.(?P<year>\\d{4})\\.(?P<month>\\d{2})\\.(?P<day>\\d{2})''',
    '''aaf-(?P<series>.*)\\.s(?P<season>\\d+)e(?P<episode>\\d+)''',
    '''(?:fever|ctu)(?:-xvid|-x264)?-(?P<series>.*)\\.(?P<season>\\d{1,2})(?P<episode>\\d{2})''',
    '''(?P<series>.*)\\.(?P<season>\\d{1,2})(?P<episode>\\d{2})\\.(?P<title>.*)(?:ws|hdtv|720p)-(?:lol|dimension)''',
    '''(?P<series>.*)\\.(?P<season>\\d+)x(?P<episode>\\d+)\\.(?P<title>.*)(?:ws|hdtv|720p).*?(?:xvid|x264|sample)-''',
    '''(?P<series>.*)\\.(?P<season>\\d{1,2})(?P<episode>\\d{2}).*?-diff''',
    '''(?P<series>.*)\\.s(?P<season>\\d+)e(?P<episode>\\d+)''',
  ].concat [ 
    # the following are shamelessly copied from http://github.com/dbr/tvnamer
    
    # [group] Show - 01-02 [Etc]
    '''^\\[.+?\\][ ]? # group name
    (?P<series>.*?)[ ]?[-_][ ]?          # show name, padding, spaces?
    (?P<episodestart>\\d+)              # first episode number
    ([-_]\\d+)*                               # optional repeating episodes
    [-_](?P<episodeend>\\d+)            # last episode number
    [^\\/]*$''',

    # [group] Show - 01 [Etc]
    '''^\\[.+?\\][ ]? # group name
    (?P<series>.*) # show name
    [ ]?[-_][ ]?(?P<episode>\\d+)
    [^\\/]*$''',

    # foo s01e23 s01e24 s01e25 *
    '''
    ^((?P<series>.+?)[ ._-])?          # show name
    [Ss](?P<season>[0-9]+)             # s01
    [. -]?                                 # separator
    [Ee](?P<episodestart>[0-9]+)       # first e23
    ([. -]+                                # separator
    [Ss]\\k<season>                    # s01
    [. -]?                                 # separator
    [Ee][0-9]+)*                             # e24 etc (middle groups)
    ([. -]+                                # separator
    [Ss]\\k<season>                    # last s01
    [. -]?                                 # separator
    [Ee](?P<episodeend>[0-9]+))        # final episode number
    [^\\/]*$''',

    # foo.s01e23e24*
    '''
    ^((?P<series>.+?)[ ._-])?          # show name
    [Ss](?P<season>[0-9]+)             # s01
    [. -]?                                 # separator
    [Ee](?P<episodestart>[0-9]+)       # first e23
    ([. -]?                                # separator
    [Ee][0-9]+)*                             # e24e25 etc
    [. -]?[Ee](?P<episodeend>[0-9]+) # final episode num
    [^\\/]*$''',

    # foo.1x23 1x24 1x25
    '''
    ^((?P<series>.+?)[ ._-])?          # show name
    (?P<season>[0-9]+)                 # first season number (1)
    [xX](?P<episodestart>[0-9]+)       # first episode (x23)
    ([ ._-]+                               # separator
    \\k<season>                        # more season numbers (1)
    [xX][0-9]+)*                             # more episode numbers (x24)
    ([ ._-]+                               # separator
    \\k<season>                        # last season number (1)
    [xX](?P<episodeend>[0-9]+))        # last episode number (x25)
    [^\\/]*$''',

    # foo.1x23x24*
    '''
    ^((?P<series>.+?)[ ._-])?          # show name
    (?P<season>[0-9]+)                 # 1
    [xX](?P<episodestart>[0-9]+)       # first x23
    ([xX][0-9]+)*                            # x24x25 etc
    [xX](?P<episodeend>[0-9]+)         # final episode num
    [^\\/]*$''',

    # foo.s01e23-24*
    '''
    ^((?P<series>.+?)[ ._-])?          # show name
    [Ss](?P<season>[0-9]+)             # s01
    [. -]?                                 # separator
    [Ee](?P<episodestart>[0-9]+)       # first e23
    (                                        # -24 etc
            [-]
            [Ee]?[0-9]+
    )*
            [-]                                # separator
            (?P<episodeend>[0-9]+)        # final episode num
    [. -]                                  # must have a separator (prevents s01e01-720p from being 720 episodes)
    [^\\/]*$''',

    # foo.1x23-24*
    '''
    ^((?P<series>.+?)[ ._-])?          # show name
    (?P<season>[0-9]+)                 # 1
    [xX](?P<episodestart>[0-9]+)       # first x23
    (                                        # -24 etc
            [-][0-9]+
    )*
            [-]                                # separator
            (?P<episodeend>[0-9]+)        # final episode num
    ([. -].*                               # must have a separator (prevents 1x01-720p from being 720 episodes)
    |
    $)''',

    # foo.[1x09-11]*
    '''^(?P<series>.+?)[ ._-]          # show name and padding
    \\[                                       # [
        ?(?P<season>[0-9]+)            # season
    [xX]                                     # x
        (?P<episodestart>[0-9]+)       # episode
        (- [0-9]+)*
    -                                        # -
        (?P<episodeend>[0-9]+)         # episode
    \\]                                       # \\]
    [^\\\\/]*$''',

    # foo.s0101, foo.0201
    '''^(?P<series>.+?)[ ._-]
    [Ss](?P<season>[0-9]{2})
    [. -]?
    (?P<episode>[0-9]{2})
    [^0-9]*$''',

    # foo.1x09*
    '''^((?P<series>.+?)[ ._-])?       # show name and padding
    \\[?                                      # [ optional
    (?P<season>[0-9]+)                 # season
    [xX]                                     # x
    (?P<episode>[0-9]+)                # episode
    \\]?                                      # ] optional
    [^\\\\/]*$''',

    # foo.s01.e01, foo.s01_e01
    '''^((?P<series>.+?)[ ._-])?
    [Ss](?P<season>[0-9]+)[. -]?
    [Ee]?(?P<episode>[0-9]+)
    [^\\\\/]*$''',

    # foo.2010.01.02.etc
    '''
    ^((?P<series>.+?)[ ._-])?         # show name
    (?P<year>\\d{4})                          # year
    [ ._-]                                 # separator
    (?P<month>\\d{2})                         # month
    [ ._-]                                 # separator
    (?P<day>\\d{2})                           # day
    [^\\/]*$''',

    # Foo - S2 E 02 - etc
    '''^(?P<series>.+?)[ ]?[ ._-][ ]?
    [Ss](?P<season>[0-9]+)[. -]?
    [Ee]?[ ]?(?P<episode>[0-9]+)
    [^\\\\/]*$''',

    # Show - Episode 9999 [S 12 - Ep 131] - etc
    '''
    (?P<series>.+)                       # Showname
    [ ]-[ ]                                  # -
    [Ee]pisode[ ]\\d+                         # Episode 1234 (ignored)
    [ ]
    \\[                                       # [
    [sS][ ]?(?P<season>\\d+)            # s 12
    ([ ]|[ ]-[ ]|-)                          # space, or -
    ([eE]|[eE]p)[ ]?(?P<episode>\\d+)   # e or ep 12
    \\]                                       # ]
    .*$                                      # rest of file
    ''',

    # foo.103*
    '''^(?P<series>.+)[ ._-]
    (?P<season>[0-9]{1})
    (?P<episode>[0-9]{2})
    [._ -][^\\\\/]*$''',

    # foo.0103*
    '''^(?P<series>.+)[ ._-]
    (?P<season>[0-9]{2})
    (?P<episode>[0-9]{2,3})
    [._ -][^\\\\/]*$''',

    # show.name.e123.abc
    '''^(?P<series>.+?)                  # Show name
    [ ._-]                                 # Padding
    [Ee](?P<episode>[0-9]+)            # E123
    [._ -][^\\\\/]*$                          # More padding, then anything
    '''
  ]

  # compile patterns into matchers
  matchers = ( XRegExp(pattern, 'xgsim') for pattern in patterns )

  # string cleaner
  clean = (string) ->
    # replace periods and underscore with space, and strip string
    string = string
            .replace(/[._]/g, ' ')
            .replace(/^\s+|\s+$/, '')
    # remove any yearstamps
    string = string.replace(/\(\d{4}\)/, '')
    # remove any trailing non-alpha's
    string = string.replace(/[^a-z0-9!?]+$/, '')
    # done
    return string

  # return matcher
  module.exports = (string) ->
    for matcher in matchers
      match = XRegExp.exec(string, matcher)
      if match
        # perform cleanup
        match.series  = clean match.series
        match.title   = clean match.title if match.title

        # titlecase series name
        match.series  = match.series.replace(/\b([a-z])/g, (m) -> m.toUpperCase())

        # parse episode and season into ints
        match.episode = parseInt(match.episode, 10) if match.episode
        match.season  = parseInt(match.season, 10)  if match.season
        return match
    return null
