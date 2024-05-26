INSERT IGNORE INTO cw_wikis (
    wiki_dbname,
    wiki_dbcluster,
    wiki_sitename,
    wiki_language,
    wiki_private,
    wiki_creation,
    wiki_category,
    wiki_closed,
    wiki_deleted,
    wiki_locked,
    wiki_inactive,
    wiki_inactive_exempt,
    wiki_url
) VALUES (
    'testwiki',
    'c1',
    'TestWiki',
    'en',
    0,
    CURRENT_TIMESTAMP,  -- Assuming the `timestamp` function returns the current timestamp
    'uncategorised',
    0,
    0,
    0,
    0,
    0,
    NULL
);
