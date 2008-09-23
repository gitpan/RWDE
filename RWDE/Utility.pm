# Macros to handle generic page functions

package RWDE::Utility;

use strict;
use warnings;

use base qw(RWDE::Logging);

use vars qw($VERSION);
$VERSION = sprintf "%d", q$Revision: 507 $ =~ /(\d+)/;

=pod  

=head2 commify()

# Return a number with commas in it for easy reading.
# From Perl Cookbook.

=cut

sub commify {
  my $text = reverse $_[0];
  $text =~ s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g;
  return scalar reverse $text;
}

=head2 get_countries_hash

Create and populate a hash with input from a comma delim string

=cut

sub get_countries_hash {
  my %countries_hash = (
    us => 'United States',
    ca => 'Canada',
    af => 'Afghanistan',
    al => 'Albania',
    dz => 'Algeria',
    as => 'American Samoa',
    ad => 'Andorra',
    ao => 'Angola',
    ai => 'Anguilla',
    aq => 'Antarctica',
    ag => 'Antigua and Barbuda',
    ar => 'Argentina',
    am => 'Armenia',
    aw => 'Aruba',
    au => 'Australia',
    at => 'Austria',
    az => 'Azerbaidjan',
    bs => 'Bahamas',
    bh => 'Bahrain',
    bd => 'Bangladesh',
    bb => 'Barbados',
    by => 'Belarus',
    be => 'Belgium',
    bz => 'Belize',
    bj => 'Benin',
    bm => 'Bermuda',
    bt => 'Bhutan',
    bo => 'Bolivia',
    ba => 'Bosnia-Herzegovina',
    bw => 'Botswana',
    bv => 'Bouvet Island',
    br => 'Brazil',
    io => 'British Indian Ocean Territory',
    bn => 'Brunei Darussalam',
    bg => 'Bulgaria',
    bf => 'Burkina Faso',
    bi => 'Burundi',
    kh => 'Cambodia',
    cm => 'Cameroon',
    cv => 'Cape Verde',
    ky => 'Cayman Islands',
    cf => 'Central African Republic',
    td => 'Chad',
    cl => 'Chile',
    cn => 'China',
    cx => 'Christmas Island',
    cc => 'Cocos (Keeling) Islands',
    co => 'Colombia',
    km => 'Comoros',
    cg => 'Congo',
    ck => 'Cook Islands',
    cr => 'Costa Rica',
    hr => 'Croatia',
    cu => 'Cuba',
    cy => 'Cyprus',
    cz => 'Czech Republic',
    dk => 'Denmark',
    dj => 'Djibouti',
    dm => 'Dominica',
    do => 'Dominican Republic',
    tp => 'East Timor',
    ec => 'Ecuador',
    eg => 'Egypt',
    sv => 'El Salvador',
    gq => 'Equatorial Guinea',
    er => 'Eritrea',
    ee => 'Estonia',
    et => 'Ethiopia',
    fk => 'Falkland Islands',
    fo => 'Faroe Islands',
    fj => 'Fiji',
    fi => 'Finland',
    cs => 'Former Czechoslovakia',
    su => 'Former USSR',
    fr => 'France',
    fx => 'France (European Territory)',
    gf => 'French Guyana',
    tf => 'French Southern Territories',
    ga => 'Gabon',
    gm => 'Gambia',
    ge => 'Georgia',
    de => 'Germany',
    gh => 'Ghana',
    gi => 'Gibraltar',
    gb => 'Great Britain',
    gr => 'Greece',
    gl => 'Greenland',
    gd => 'Grenada',
    gp => 'Guadeloupe (French)',
    gu => 'Guam (USA)',
    gt => 'Guatemala',
    gn => 'Guinea',
    gw => 'Guinea Bissau',
    gy => 'Guyana',
    ht => 'Haiti',
    hm => 'Heard and McDonald Islands',
    hn => 'Honduras',
    hk => 'Hong Kong',
    hu => 'Hungary',
    is => 'Iceland',
    in => 'India',
    id => 'Indonesia',
    ir => 'Iran',
    iq => 'Iraq',
    ie => 'Ireland',
    il => 'Israel',
    it => 'Italy',
    ci => 'Ivory Coast (Cote D\'Ivoire)',
    jm => 'Jamaica',
    jp => 'Japan',
    jo => 'Jordan',
    kz => 'Kazakhstan',
    ke => 'Kenya',
    ki => 'Kiribati',
    kw => 'Kuwait',
    kg => 'Kyrgyzstan',
    la => 'Laos',
    lv => 'Latvia',
    lb => 'Lebanon',
    ls => 'Lesotho',
    lr => 'Liberia',
    ly => 'Libya',
    li => 'Liechtenstein',
    lt => 'Lithuania',
    lu => 'Luxembourg',
    mo => 'Macau',
    mk => 'Macedonia',
    mg => 'Madagascar',
    mw => 'Malawi',
    my => 'Malaysia',
    mv => 'Maldives',
    ml => 'Mali',
    mt => 'Malta',
    mh => 'Marshall Islands',
    mq => 'Martinique (French)',
    mr => 'Mauritania',
    mu => 'Mauritius',
    yt => 'Mayotte',
    mx => 'Mexico',
    fm => 'Micronesia',
    md => 'Moldavia',
    mc => 'Monaco',
    mn => 'Mongolia',
    ms => 'Montserrat',
    ma => 'Morocco',
    mz => 'Mozambique',
    mm => 'Myanmar',
    na => 'Namibia',
    nr => 'Nauru',
    np => 'Nepal',
    nl => 'Netherlands',
    an => 'Netherlands Antilles',
    nt => 'Neutral Zone',
    nc => 'New Caledonia (French)',
    nz => 'New Zealand',
    ni => 'Nicaragua',
    ne => 'Niger',
    ng => 'Nigeria',
    nu => 'Niue',
    nf => 'Norfolk Island',
    kp => 'North Korea',
    mp => 'Northern Mariana Islands',
    no => 'Norway',
    om => 'Oman',
    pk => 'Pakistan',
    pw => 'Palau',
    pa => 'Panama',
    pg => 'Papua New Guinea',
    py => 'Paraguay',
    pe => 'Peru',
    ph => 'Philippines',
    pn => 'Pitcairn Island',
    pl => 'Poland',
    pf => 'Polynesia (French)',
    pt => 'Portugal',
    pr => 'Puerto Rico',
    qa => 'Qatar',
    re => 'Reunion (French)',
    ro => 'Romania',
    ru => 'Russian Federation',
    rw => 'Rwanda',
    gs => 'S. Georgia &amp; S. Sandwich Isls.',
    sh => 'Saint Helena',
    kn => 'Saint Kitts &amp; Nevis Anguilla',
    lc => 'Saint Lucia',
    pm => 'Saint Pierre and Miquelon',
    st => 'Saint Tome and Principe',
    vc => 'Saint Vincent &amp; Grenadines',
    ws => 'Samoa',
    sm => 'San Marino',
    sa => 'Saudi Arabia',
    sn => 'Senegal',
    sc => 'Seychelles',
    sl => 'Sierra Leone',
    sg => 'Singapore',
    sk => 'Slovak Republic',
    si => 'Slovenia',
    sb => 'Solomon Islands',
    so => 'Somalia',
    za => 'South Africa',
    kr => 'South Korea',
    es => 'Spain',
    lk => 'Sri Lanka',
    sd => 'Sudan',
    sr => 'Suriname',
    sj => 'Svalbard and Jan Mayen Islands',
    sz => 'Swaziland',
    se => 'Sweden',
    ch => 'Switzerland',
    sy => 'Syria',
    tj => 'Tadjikistan',
    tw => 'Taiwan',
    tz => 'Tanzania',
    th => 'Thailand',
    tg => 'Togo',
    tk => 'Tokelau',
    to => 'Tonga',
    tt => 'Trinidad and Tobago',
    tn => 'Tunisia',
    tr => 'Turkey',
    tm => 'Turkmenistan',
    tc => 'Turks and Caicos Islands',
    tv => 'Tuvalu',
    ug => 'Uganda',
    ua => 'Ukraine',
    ae => 'United Arab Emirates',
    uk => 'United Kingdom',
    uy => 'Uruguay',
    ut => 'US Territories',
    um => 'USA Minor Outlying Islands',
    uz => 'Uzbekistan',
    vu => 'Vanuatu',
    va => 'Vatican City State',
    ve => 'Venezuela',
    vn => 'Vietnam',
    vg => 'Virgin Islands (British)',
    vi => 'Virgin Islands (USA)',
    wf => 'Wallis and Futuna Islands',
    eh => 'Western Sahara',
    ye => 'Yemen',
    yu => 'Yugoslavia',
    zr => 'Zaire',
    zm => 'Zambia',
    zw => 'Zimbabwe',
  );
  return \%countries_hash;
}

=head2 get_countries_hash

Create and populate a hash with input from a comma delim string

=cut

sub get_states_hash {

  my %states_hash = (
    al => 'Alabama',
    ak => 'Alaska',
    az => 'Arizona',
    ar => 'Arkansas',
    ca => 'California',
    co => 'Colorado',
    ct => 'Connecticut',
    de => 'Delaware',
    dc => 'District of Columbia',
    fl => 'Florida',
    ga => 'Georgia',
    hi => 'Hawaii',
    id => 'Idaho',
    il => 'Illinois',
    in => 'Indiana',
    ia => 'Iowa',
    ks => 'Kansas',
    ky => 'Kentucky',
    la => 'Louisiana',
    me => 'Maine',
    md => 'Maryland',
    ma => 'Massachusetts',
    mi => 'Michigan',
    mn => 'Minnesota',
    ms => 'Mississippi',
    mo => 'Missouri',
    mt => 'Montana',
    ne => 'Nebraska',
    nv => 'Nevada',
    nh => 'New Hampshire',
    nj => 'New Jersey',
    nm => 'New Mexico',
    ny => 'New York',
    nc => 'North Carolina',
    nd => 'North Dakota',
    oh => 'Ohio',
    ok => 'Oklahoma',
    or => 'Oregon',
    pa => 'Pennsylvania',
    ri => 'Rhode Island',
    sc => 'South Carolina',
    sd => 'South Dakota',
    tn => 'Tennessee',
    tx => 'Texas',
    ut => 'Utah',
    vt => 'Vermont',
    va => 'Virginia',
    wa => 'Washington',
    wv => 'West Virginia',
    wi => 'Wisconsin',
    wy => 'Wyoming',
    ab => 'Alberta',
    bc => 'British Columbia',
    mb => 'Manitoba',
    nt => 'N.W. Territories',
    nb => 'New Brunswick',
    nl => 'Newfoundland and Labrador',
    ns => 'Nova Scotia',
    nu => 'Nunavut',
    on => 'Ontario',
    pe => 'Prince Edward Island',
    qc => 'Quebec',
    sk => 'Saskatchewan',
    yt => 'Yukon',
  );

  return \%states_hash;
}

sub get_provinces_hash {

  my %provinces_hash = (
    ab => 'Alberta',
    bc => 'British Columbia',
    mb => 'Manitoba',
    nt => 'N.W. Territories',
    nb => 'New Brunswick',
    nl => 'Newfoundland and Labrador',
    ns => 'Nova Scotia',
    nu => 'Nunavut',
    on => 'Ontario',
    pe => 'Prince Edward Island',
    qc => 'Quebec',
    sk => 'Saskatchewan',
    yt => 'Yukon',
  );

  return \%provinces_hash;
}

sub terminate ($$) {
  my ($self, $msg, $status) = @_;

  $self->syslog_msg('devel', $msg);

  exit($status);
}

1;