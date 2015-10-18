require 'mathnet/crawler'
require 'webmock/rspec'

Library = Mathnet::Crawler::Library
Journal = Mathnet::Crawler::Journal
Issue = Mathnet::Crawler::Issue
Article = Mathnet::Crawler::Article

RSpec.describe Journal, '#list' do
  before :each do
    @download_link = 'www.mathnet.ru/ej.phtml'
  end

  it 'single journal' do
    single_journal = %q(
    <table><tbody><tr>
      <td><a name="JPUBLISHER8"><b><i>Российская академия наук,
      Отделение математических наук</i></b></a></td>
    </tr>
    <tr>
      <td><a class="SLink" title="Алгебра и анализ"
        href="/php/journal.phtml?jrnid=aa&amp;option_lang=rus">
        Алгебра и анализ
      </a></td>
      <td>Свободный доступ к полным текстам предоставляется по прошествии
      трех лет с момента выхода соответствующего номера журнала</td>
    </tr></tbody></table>
    )
    stub_request(:get, @download_link)
      .to_return(status: 200, body: single_journal, headers: {})
    journals = Journal.list Library.new
    expect(journals).to be_a Array
    expect(journals.size).to eq 1
    expect(journals[0].title).to eq 'Алгебра и анализ'
    expect(journals[0].children_url).to eq '/php/archive.phtml' \
      '?wshow=contents&jrnid=aa&option_lang=rus'
  end

  it 'no journals' do
    stub_request(:get, @download_link)
      .to_return(status: 200, body: '', headers: {})
    journals = Journal.list Library.new
    expect(journals).to be_a Array
    expect(journals).to eq []
  end

  it 'raise socket error' do
    stub_request(:get, @download_link)
      .to_raise SocketError
    expect { Journal.list Library.new } .to raise_error SocketError
  end

  it 'raise server exception' do
    stub_request(:get, @download_link)
      .to_return(status: 400, body: '', headers: {})
    expect { Journal.list Library.new } .to raise_error Net::HTTPServerException
  end
end

RSpec.describe Issue, '#list' do
  before :each do
    tag = { 'title' => 'Test', 'href' => '/php/journal.phtml?jrnid=aa' }
    @journal = Journal.new Library.new, tag
    @download_link = 'www.mathnet.ru/php/archive.phtml?jrnid=aa&wshow=contents'
  end

  it 'single issue' do
    issue_link = '/php/archive.phtml?jrnid=da&wshow=issue&series=0' \
      '&year=2015&volume=22&volume_alt=&issue=1&issue_alt=&option_lang=rus'
    single_issue = %(
    <table><tbody><tr>
      <td"7"><br>Дискретный анализ и исследование операций</td>
    </tr>
    <tr><td>
      <img align="absmiddle" src="/gifs/wvols.gif" border="0">  том 22, 2015
      <a class="SLink" target="_top"
        href="/php/contents.phtml?jrnid=da&amp;wshow=aindex&amp;year=2015
        &amp;volume=22&amp;volume_alt=&amp;option_lang=rus">Именной указатель
      </a>
    </td></tr>
    <tr>
    <td class="series"></td>
    <td title="Дискретн. анализ и исслед. опер.,  том 22, 2015,  номер 1">
      <a title="Дискретн. анализ и исслед. опер.,  том 22, 2015,  номер 1"
      class="SLink" href="#{issue_link}">
        <nobr>1</nobr>
      </a>
    </td>
    <img align="absmiddle" src="/gifs/wvols.gif" border="0">  том&nbsp;21, 2014
      <a class="SLink" target="_top"
      href="Дискретн. анализ и исслед. опер.,  том 22, 2015,  номер 1">
      Именной указатель
      </a>
    </tr>
    </tbody></table>
    )
    stub_request(:get, @download_link)
      .to_return(status: 200, body: single_issue, headers: {})
    issues = Issue.list @journal
    expect(issues).to be_a Array
    expect(issues.size).to eq 1
    expect(issues[0].title).to eq 'Дискретн. анализ и исслед. опер.,  том 22' \
      ', 2015,  номер 1'
    expect(issues[0].children_url).to eq issue_link
  end

  it '3 issues' do
    issue_links = [
      '/php/archive.phtml?jrnid=da&amp;wshow=issue&amp;' \
        'series=0&amp;year=2015&amp;volume=22&amp;volume_alt=&amp;' \
        'issue=1&amp;issue_alt=&amp;option_lang=rus',
      '/php/archive.phtml?jrnid=da&amp;wshow=issue&amp;series=0&amp;' \
        'year=2012&amp;volume=19&amp;volume_alt=&amp;issue=1&amp;' \
        'issue_alt=&amp;option_lang=rus',
      '/php/archive.phtml?' \
        'jrnid=da&amp;wshow=issue&amp;series=0&amp;year=2011&amp;' \
        'volume=18&amp;volume_alt=&amp;issue=1&amp;issue_alt=&amp;' \
        'option_lang=rus'
    ]
    three_issues = %(
    <table><tbody>
    <tr>
    <td title="Дискретн. анализ и исслед. опер.,  том 22, 2015,  номер 1">
      <a title="Дискретн. анализ и исслед. опер.,  том 22, 2015,  номер 1"
      class="SLink" href="#{issue_links[0]}"><nobr>1</nobr>
      </a>
    </td>
    <img align="absmiddle" src="/gifs/wvols.gif" border="0">  том 21, 2014
      <a class="SLink" target="_top" href="Дискретн. анализ и исслед. опер.,
      том&nbsp;22, 2015,  номер&nbsp;1">Именной указатель</a></td>
    <td title="Дискретн. анализ и исслед. опер.,  том&nbsp;19, 2012,
      номер&nbsp;1 Доступны полные тексты статей"class="issue_with_corner"
      align="center">
      <a title="Дискретн. анализ и исслед. опер.,  том 19, 2012,  номер 1"
      class="SLink"
      href="#{issue_links[1]}"><nobr>1</nobr></a>
    </td>
    </tr>
    <tr>
    <td title="Дискретн. анализ и исслед. опер.,  том&nbsp;18, 2011,
      номер&nbsp;1 Доступны полные тексты статей" class="issue_with_corner"
      align="center">
      <a title="Дискретн. анализ и исслед. опер.,  том 18, 2011,  номер 1"
        class="SLink" href="#{issue_links[2]}">
        <nobr>1</nobr>
      </a>
    </td>
    </tr>
    </tbody></table>
    )
    stub_request(:get, @download_link)
      .to_return(status: 200, body: three_issues, headers: {})
    issues = Issue.list @journal
    expect(issues).to be_a Array
    expect(issues.size).to eq 3
    expect(issues[0].title).to eq 'Дискретн. анализ и исслед. опер.,  том 22' \
      ', 2015,  номер 1'
    expect(issues[0].children_url).to eq '/php/archive.phtml?jrnid=da&' \
      'wshow=issue&series=0&year=2015&volume=22&volume_alt=&issue=1&' \
      'issue_alt=&option_lang=rus'
    expect(issues[1].title).to eq 'Дискретн. анализ и исслед. опер.,  том 19' \
      ', 2012,  номер 1'
    expect(issues[1].children_url).to eq '/php/archive.phtml?jrnid=da&' \
      'wshow=issue&series=0&year=2012&volume=19&volume_alt=&issue=1&' \
      'issue_alt=&option_lang=rus'
    expect(issues[2].title).to eq 'Дискретн. анализ и исслед. опер.,  том 18' \
      ', 2011,  номер 1'
    expect(issues[2].children_url).to eq '/php/archive.phtml?jrnid=da&' \
      'wshow=issue&series=0&year=2011&volume=18&volume_alt=&issue=1&' \
      'issue_alt=&option_lang=rus'
  end

  it 'no issues' do
    stub_request(:get, @download_link)
      .to_return(status: 200, body: '', headers: {})
    issues = Issue.list @journal
    expect(issues).to be_a Array
    expect(issues).to eq []
  end

  it 'raise socket error' do
    stub_request(:get, @download_link)
      .to_raise SocketError
    expect { Issue.list @journal } .to raise_error SocketError
  end

  it 'raise server exception' do
    stub_request(:get, @download_link)
      .to_return(status: 400, body: '', headers: {})
    expect { Issue.list @journal } .to raise_error Net::HTTPServerException
  end
end

RSpec.describe Article, '#list' do
  before :each do
    journal_tag = {
      'title' => 'Test',
      'href' => '/php/journal.phtml?jrnid=aa'
    }
    journal = Journal.new Library.new, journal_tag
    issues_tag = {
      'title' => 'Test issue 1',
      'href' => '/php/archive.phtml?jrnid=da&wshow=issue&series=0&year=2015&' \
        'volume=22&volume_alt=&issue=1&issue_alt=&option_lang=rus'
    }
    @issue = Issue.new journal, issues_tag
    @download_link = 'www.mathnet.ru/php/archive.phtml?issue=1&issue_alt=&' \
      'jrnid=da&option_lang=rus&series=0&volume=22&volume_alt=&wshow=issue&' \
      'year=2015'
  end

  it 'single issue' do
    issue_title = 'Алгоритм ветвей и границ для задачи конкурентного ' \
      'размещения предприятий с предписанным выбором поставщиков'
    single_journal = %(
    <table><tbody><tr>
      <td valign="top" width="11">
        <img title="Доступен полный текст статьи" align="absmiddle"
        src="/gifs/wvolsa.gif" border="0">
      </td>
      <td colspan="2" width="90%" valign="top" align="left">
        <a class="SLink" href="/rus/da763">#{issue_title}</a>
        <br>В. Л. Береснев, А. А. Мельников
      </td>
      <td valign="top" align="right">3</td>
      </tr></tbody></table>
    )
    stub_request(:get, @download_link)
      .to_return(status: 200, body: single_journal, headers: {})
    articles = Article.list @issue
    expect(articles).to be_a Array
    expect(articles.size).to eq 1
    expect(articles[0].title).to eq issue_title
    expect(articles[0].children_url).to eq '/rus/da763'
  end

  it '3 issues' do
    issue_titles = [
      'Пороговое свойство квадратичных булевых функций',
      'Функция Шеннона быстрого вычисления сложности по Арнольду ' \
        'двоичных слов длины',
      'Совершенные 22-раскраски бесконечных циркулянтных графов со сплошным' \
        'набором дистанций'
    ]
    single_journal = %(
    <table><tbody>
    <tr>
      <td valign="top" width="11">
        <img title="Доступен полный текст статьи" align="absmiddle"
        src="/gifs/wvolsa.gif" border="0">
      </td>
      <td colspan="2" width="90%" valign="top" align="left">
        <a class="SLink" href="/rus/da766">#{issue_titles[0]}</a>
        <br>Н.&nbsp;А.&nbsp;Коломеец
      </td>
      <td valign="top" align="right">52</td>
    </tr>
    <tr>
      <td valign="top" width="11">
        <img title="Доступен полный текст статьи" align="absmiddle"
        src="/gifs/wvolsa.gif" border="0">
      </td>
      <td colspan="2" width="90%" valign="top" align="left">
        <a class="SLink" href="/rus/da767">#{issue_titles[1]}</a>
        <br>Ю.&nbsp;В.&nbsp;Мерекин
      </td>
      <td valign="top" align="right">59</td>
    </tr>
    <tr>
      <td valign="top" width="11">
        <img title="Доступен полный текст статьи" align="absmiddle"
        src="/gifs/wvolsa.gif" border="0">
      </td>
      <td colspan="2" width="90%" valign="top" align="left">
        <a class="SLink" href="/rus/da768">#{issue_titles[2]}</a>
        <br>О.&nbsp;Г.&nbsp;Паршина
      </td>
      <td valign="top" align="right">76</td>
    </tr>
    </tbody></table>
    )
    stub_request(:get, @download_link)
      .to_return(status: 200, body: single_journal, headers: {})
    articles = Article.list @issue
    expect(articles).to be_a Array
    expect(articles.size).to eq 3
    expect(articles[0].title).to eq issue_titles[0]
    expect(articles[0].children_url).to eq '/rus/da766'
    expect(articles[1].title).to eq issue_titles[1]
    expect(articles[1].children_url).to eq '/rus/da767'
    expect(articles[2].title).to eq issue_titles[2]
    expect(articles[2].children_url).to eq '/rus/da768'
  end

  it 'no issues' do
    stub_request(:get, @download_link)
      .to_return(status: 200, body: '', headers: {})
    articles = Article.list @issue
    expect(articles).to be_a Array
    expect(articles).to eq []
  end

  it 'raise socket error' do
    stub_request(:get, @download_link)
      .to_raise SocketError
    expect { Article.list @issue } .to raise_error SocketError
  end

  it 'raise server exception' do
    stub_request(:get, @download_link)
      .to_return(status: 400, body: '', headers: {})
    expect { Article.list @issue } .to raise_error Net::HTTPServerException
  end
end

RSpec.describe Article, '#full_text' do
  before :each do
    journal_tag = {
      'title' => 'Test',
      'href' => '/php/journal.phtml?jrnid=aa'
    }
    journal = Journal.new Library.new, journal_tag
    issues_tag = {
      'title' => 'Test issue 1',
      'href' => '/php/archive.phtml?jrnid=da&wshow=issue&series=0&year=2015&' \
        'volume=22&volume_alt=&issue=1&issue_alt=&option_lang=rus'
    }
    issue = Issue.new journal, issues_tag
    article_tag = double('Article Tag', text: 'Article')
    allow(article_tag).to receive(:[]).with('title').and_return 'Test article 1'
    allow(article_tag).to receive(:[]).with('href').and_return '/rus/da766'
    @article = Article.new issue, article_tag
    @download_link = 'www.mathnet.ru/rus/da766'
    @full_text_url = '/php/getFT.phtml?jrnid=da&paperid=763&what=fullt&' \
      'option_lang=rus'
    @full_text_link = "www.mathnet.ru#{@full_text_url}"
  end

  it 'single issue' do
    single_journal = %(
    <a class="SLink" href="#{@full_text_url}">PDF файл</a>
    )
    stub_request(:get, @download_link)
      .to_return(status: 200, body: single_journal, headers: {})
    stub_request(:get, @full_text_link)
      .to_return(status: 200, body: single_journal, headers: {})
    @article.full_text {}
  end

  it 'no full test' do
    single_journal = ''
    stub_request(:get, @download_link)
      .to_return(status: 200, body: single_journal, headers: {})
    expect { @article.full_text {} } .to raise_error ArgumentError
  end
end
