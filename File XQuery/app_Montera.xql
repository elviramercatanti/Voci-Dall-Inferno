xquery version "3.1";


(:~ This is the default application library module of the applet app.
 :
 : @author Greta Montera
 : @version 1.0.0
 : @see http://exist-db.org
 :)

(: Module for app-specific template functions :)
module namespace app="http://exist-db.org/apps/applet/templates";
import module namespace templates = "http://exist-db.org/xquery/html-templating";
import module namespace lib = "http://exist-db.org/xquery/html-templating/lib";
import module namespace config = "http://exist-db.org/apps/applet/config" at "config.xqm";
(: TEI IMPORTATO PER LA RAPPRESENTAZIONE DEGLI ELEMENTI XML :)
declare  namespace tei = "http://www.tei-c.org/ns/1.0";
declare option exist:serialize "method=xhtml media-type=text/html";



(: funzione per la collezione :)
declare function app:collezione($node as node(), $model as map (*)){
let $doc-info :=
<docs>
{
    for $resource in collection("/db/apps/tesiapplet/Codifica")
    return 
        <documento uri="{base-uri($resource)}"
        name="{util:unescape-uri(replace(base-uri($resource), ".+/(.+)$", "$1"), "UTF-8")}">
        {
            $resource/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/text()
        }
        </documento>
}

</docs>
return  (: abbiamo bisogno di usare il return perchè dopo aver creato la variabile 
        con let := allora siamo entrati nell'ambito di FLOWR che necessita del return :)

<html>
    <head>
        <meta HTTP-EQUIV="Content-Type" content="text/html; charset=UTF-8"/>
        <title>{"I documenti della collezione"}</title>
    </head>
    <body>
        <h1 id="titolo_home">{"I documenti della collezione"}</h1>
            <div id="lista_documenti">
            <ul id="lista_interna_documenti">
                {
                    for $documento in $doc-info/documento
                    return 
                    <li> 
                        {string($documento)} 
                        ({string($documento/@name)})
                        <img src="resources/images/folder.png" class="img_collezione"/>
                    </li>
                    }
                
            </ul> 
            <!--ogni documento deve essere inserita qui per essere rappresentata nella pagina della collezione-->
                <h2>{"Link"}</h2>
                <div id="lista_link">
                <div id="lista_link_interna">
                    <div class="link">
                        <h4>Diario</h4>
                            <a href="/exist/apps/tesiapplet/index.html">Vai al documento</a> 
                            <a href="/exist/apps/tesiapplet/diario.html">Vai al diario</a>
                    </div>
                    <div class="link">
                        <h4>Secondo manoscritto</h4>
                            <a href="/exist/apps/tesiapplet/">Vai al documento</a> 
                            <a href="/exist/apps/tesiapplet/">Vai al diario</a>
                    </div>
                    <div class="link">
                    <h4>Terzo manoscritto</h4>
                        <a href="/exist/apps/tesiapplet/">Vai al documento</a> 
                        <a href="/exist/apps/tesiapplet/">Vai al diario</a>
                    </div>
                    <div class="link">
                    <h4>Quarto manoscritto</h4>
                        <a href="/exist/apps/tesiapplet/">Vai al documento</a> 
                        <a href="/exist/apps/tesiapplet/">Vai al diario</a>
                    </div>
                    <div class="link">
                    <h4>Quinto manoscritto</h4>
                        <a href="/exist/apps/tesiapplet/">Vai al documento</a> 
                        <a href="/exist/apps/tesiapplet/">Vai al diario</a>
                    </div>
                    <div class="link">
                    <h4>Sesto manoscritto</h4>
                        <a href="/exist/apps/tesiapplet/">Vai al documento</a> 
                        <a href="/exist/apps/tesiapplet/">Vai al diario</a>
                    </div>
                </div>
            </div>
            </div>
    </body>
</html>
};






(: FUNZIONI PAGINA DI INDEX ......................................................................................................:)
(: funzione logo exist :)
declare function app:exist($node as node(), $model as map (*))
{
   <img src ="resources/images/existdb.png" class="loghi" id="exist_icon"/> 
   
 
};
(: funzione logo unipi :)

declare function app:unipi($node as node(), $model as map (*))
{
   <img src ="resources/images/University_of_Pisa.svg.png" class="loghi" id="unipi_icon"/> 
   
 
};


(: funzione icona :)
declare function app:iconindex($node as node(), $model as map (*))
{
   <img src ="resources/images/edit-code.png" class="sfondo" id="icon"/> 
   
 
};
(: testo index :)
declare function app:test($node as node(), $model as map (*))
{
    <p> Codificare un testo manoscritto significa analizzarne l'aspetto strutturale e semantico dei fenomeni linguistici ed extralinguistici così da rendere esplicite tutte le sue intepretazioni al computer, che conserva e  mantiene. Tutto questo è possibile soltanto grazie ai nuovi strumenti informatici, primo tra tutti il linguaggio di mark-up XML attraverso cui la TEI ha declinato le sue regole per rendere il più preciso possibile il compito di chi codifica, inserendo set di tag adatti ad ogni situazione. Ed è proprio grazie a tali strumenti che è possibile, come in questo caso, digitalizzare una parte di un manoscritto (le uniche due pagine rimaste) che racconta un pezzo della nostra storia, è il viaggio di Bruno Cimoli verso i campi di concentramento della Germania, raccontato nel suo diario, o di quello che ora ne rimane. </p>
};
(:  funzione che mostra il banner della tei:)

declare function app:bannertei($node as node(), $model as map (*)){
<img src ="resources/images/banner.jpg" class="sfondo" id="banner"/> 

};
(: secondo testo che riprende le frasi iniziali del diario originale :)

declare function app:test2($node as node(), $model as map (*))
{
    <p><strong>“Questa è una copiatura del Diario che volevo poter compilare durante la prigionia e la deportazioneE che non sono riuscito a farne più di tanto perché non avevo né le matite e, confesso, neanche tanta voglia, con tutto quello che ho visto giorno per giorno.
        Il foglio originale è molto sgualcito e nelle piegature si sono perdute alcune parole! Comunque, trascrivo quello che riesco avedere!”</strong> <br/>
        Tale premessa scritta da Bruno introduce le varie tappe che lo portarono, nel settembre del 1944 da Carrara, luogo della cattura, fino alla località di Fossoli, per poi essere diretto ad Innsbruck, centro di smistamento e di identificazione.
</p>
};

(:  titolo della pagina:)

declare function app:titolo($node as node(), $model as map (*))
{
    <div class="titoli_classe"><h1>Codifica del Diario di Bruno Cimoli</h1></div>
};

(: sottotitolo :)
declare function app:sottotitolo($node as node(), $model as map (*))
{
    <h2>Per il progetto "Voci dall'inferno"</h2>
};

(:  informazione sulla pubblicazione:)

declare function app:pubblicazione($node as node(), $model as map(*)) {
    let $lettere:= doc("/db/apps/tesiapplet/Codifica/manoscrittoBC.xml")//tei:publicationStmt
                return 
                    <p>
                            {$lettere//tei:publisher/text()}
                            {$lettere//tei:pubPlace/text()}
                            {$lettere//tei:address//tei:postCode/text()}
                            {$lettere//tei:address//tei:name/text()}
                  </p>
};

(: info sulla trasposizione :)
declare function app:trasposizione($node as node(), $model as map(*)) {
    let $resp:= doc("/db/apps/tesiapplet/Codifica/manoscrittoBC.xml")//tei:respStmt
                return 
                        <p>
                            {$resp//tei:respStmt[@xml:id="TRASP"]}
                            {$resp//tei:resp[@xml:id="RESP_TRASP"]}
                            {$resp//tei:name[@xml:id="BC"]}
                        </p>
};


(: responsabili :)

declare function app:responsabili($node as node(), $model as map(*)) {
    let $resp:= doc("/db/apps/tesiapplet/Codifica/manoscrittoBC.xml")//tei:respStmt
                return <p>
                            {$resp//tei:resp[@xml:id="RESP_COD"]}
                            {$resp//tei:name[@xml:id="GM"]}
                            <br/>{$resp//tei:resp[@xml:id="RESP_PROG"]}
                            {$resp//tei:name[@xml:id="AMDG"]} 
                            e{$resp//tei:name[@xml:id="MR"]}
                        </p>
};
(: FUNZIONI PAGINA GIORNATE :)
declare function app:giornatetitolo($node as node(), $model as map (*))
{
   <div class="titoli_classe"><h1>Le giornate del diario</h1></div> 
};
declare function app:icongiornate($node as node(), $model as map (*))
{
   <img src ="resources/images/schedule.png" class="sfondo" id="icon"/> 
   
 
};

(: ogni giornata è contenuta in un div con attributo type e valore day, ogni giornata restituita accanto all'immagine del manoscritto corrispondente:) 
declare function app:giornate($node as node(), $model as map (*))
{
    let $giornate:= doc("/db/apps/tesiapplet/Codifica/manoscrittoBC.xml")//tei:div[@type="day"]
    return
        for $giornata in $giornate
        return 
            if ($giornata/@n="1") then
                <div id="giornate"><div class="titolo_testo_giornate">{$giornata}
                <h3>Primo giorno</h3> </div>
                <img src="resources/images/giorno1.jpeg"/>
                </div>
            else if ($giornata/@n="2") then
                <div id="giornate"><div class="titolo_testo_giornate">{$giornata}
                <h3>Secondo giorno</h3> </div>
                <img src="resources/images/giorno2.jpeg"/>
                </div>
            else if ($giornata/@n="3") then
                <div id="giornate"><div class="titolo_testo_giornate">{$giornata}
                <h3>Terzo giorno</h3></div>
                <img src="resources/images/giorno3.jpeg"/>
                </div>
            else if (($giornata/@n="4") and ($giornata/@part="I")) then
                <div id="giornate"><div class="titolo_testo_giornate">{$giornata}
                <h3>Quarto giorno prima parte</h3></div>
                <div id="giorno_4_1_imgs">
                <img src="resources/images/giorno4-1.jpeg" id="giornate_prima_quarta"/>
                <!--<img src="resources/images/giorno4-2.jpeg"/>-->
                </div>
                </div>
            else if (($giornata/@n="4") and ($giornata/@part="F"))  then
                <div id="giornate"><div class="titolo_testo_giornate">{$giornata}
                <h3>Quarto giorno seconda parte</h3></div>
                <div id="giorno_4_2_imgs">
                <img src="resources/images/giorno4-2.jpeg"/>
                </div>
                </div>
            else if ($giornata/@n="5") then
                <div id="giornate"> <div class="titolo_testo_giornate">{$giornata}
                <h3>Quinto giorno</h3></div>
                <img src="resources/images/giorno5.jpeg"/>
                </div>
            else if ($giornata/@n="6") then
                <div id="giornate"> <div class="titolo_testo_giornate">{$giornata}
                <h3>Sesto giorno</h3> </div>
                <img src="resources/images/giorno6.jpeg"/>
                </div>
            else if ($giornata/@n="7") then
                <div id="giornate"> <div class="titolo_testo_giornate">{$giornata}
                <h3>Settimo giorno</h3></div>
                <img src="resources/images/giorno7.jpeg"/>
                </div>
            else  
                <div id="giornate"> <div class="titolo_testo_giornate">{$giornata}
                <h3>Ottavo giorno</h3> </div>
                <img src="resources/images/giorno8.jpeg"/>
                </div>
                

  
    

};

(: viene fatto per ogni giorno, in tutto 8:) 

(: FUNZIONI PAGINA DIARIO ......................................................................................................:)
declare function app:diariotitolo($node as node(), $model as map (*))
{
    <div class="titoli_classe"><h1>Il diario di Bruno</h1></div>
};

declare function app:icon($node as node(), $model as map (*))
{
   <img src ="resources/images/inkwell.png" class="sfondo" id="icon"/> 
   
 
};


declare function app:diariotesto($node as node(), $model as map (*))
{
    <p>Di seguito sono riportate le scansioni delle uniche due pagine del Diario di viaggio di Bruno Cimoli; inoltre ho inserito anche il testo dattiloscritto dei fogli di modo che il contenuto sia leggibile anche in formato digitale.</p>
};

declare function app:diariotesto2($node as node(), $model as map (*))
{
    <p>Il negativo delle pagine del diario è stato necessario date le pessime condizioni del manoscritto originale. In questo modo è stato più semplice individuare i fenomeni testuali illeggibili a causa di fattori esterni incontrollabili.</p>
};

(:  immagini del diario:)
declare function app:immagineprima($node as node(), $model as map (*))
{
    <img src="resources/images/primaPagina.jpeg" id="primafoto" alt="prima"/>
};

declare function app:immagineseconda($node as node(), $model as map (*))
{
    <img src="resources/images/secondaPagina.jpeg" id="secondafoto" alt="seconda"/>
};

declare function app:immagineterza($node as node(), $model as map (*))
{
    <img src="resources/images/fotonegativa.jpeg" id="terzafoto" alt="terza"/>
};

(:  sezione di testo con informazioni estrapolate da XML:)
declare function app:descrizione($node as node(), $model as map(*)){
    let $desc := doc("/db/apps/tesiapplet/Codifica/manoscrittoBC.xml")//tei:sourceDesc//tei:msDesc//tei:msIdentifier//tei:placeName
        return <p> Il manoscritto è stato trovato presso la sede di 
                    {$desc//tei:orgName/text()}
                    a {$desc//tei:settlement/text()},
                    {$desc//tei:region/text()}
                </p>    
};

declare function app:dfisica($node as node(), $model as map(*)){
    let $fis:= doc("/db/apps/tesiapplet/Codifica/manoscrittoBC.xml")//tei:physDesc//tei:supportDesc
        return <p>
            {$fis//tei:support/text()}
            {$fis//tei:material/text()}
            {$fis//tei:extent/text()}
            {$fis//tei:condition/text()}
            
            </p>
    
    
};
declare function app:dfisica2($node as node(), $model as map(*)) {
    let $fis2:= doc("/db/apps/tesiapplet/Codifica/manoscrittoBC.xml")//tei:physDesc
        return <p>
            {$fis2//tei:handDesc/text()}
            </p>
};

(:  testo dei bottoni:)

declare function app:bottonitesto($node as node(), $model as map (*))
{
    <p>Premi per individuare più facilmente i luoghi ed i personaggi del racconto del viaggio di Bruno</p>
};

declare function app:righedoctitolo1($node as node(), $model as map (*))
{
    <h3>Primo foglio</h3>
};





(: funzione che trova il testo contenuto tra due lb, tag che indicano l'inizio di riga, il contenuto dell'intervallo corrisponde a una riga, a ogni riga è associato un bottone che in html fa apparire la freccia nel punto corrispondente dellìimmagine:) 
declare function app:righedocumento($node as node(), $model as map(*)){
    let $enunciati := doc("/db/apps/tesiapplet/Codifica/manoscrittoBC.xml")//tei:body/tei:div[@type="pagina"][@n="1"]
    let $days := doc("/db/apps/tesiapplet/Codifica/manoscrittoBC.xml")//tei:body/tei:div[@type="pagina"][@n="1"]/tei:div[@type="day"]
    for $day in $days
        return
            <div>
                    { for $e in $day/child::node()
                    let $riga := $e/preceding-sibling::tei:lb[1]/@n
                   
                        return if (name($e)!='lb' or (name($e)='opener')) then <span data-riga="{$riga}" data-name="{name($e)}">{string($e)}</span> 
                        else    (<button class="bottoni_righe" onclick="freccia_riga({$riga})"><a href="#primaFoto">{string($riga)}</a></button>,
                        <span data-riga="{$riga}" data-name="{name($e)}">{string($e)}</span> )
                        
                        
                    }
            </div>
};

declare function app:righedoctitolo2($node as node(), $model as map (*))
{
    <h3>Secondo foglio</h3>
};

(: stessa cosa della funzione precedente ma fatta sulle righe della seconda pagina:)
declare function app:righedocumento2($node as node(), $model as map(*)){
    let $enunciati := doc("/db/apps/tesiapplet/Codifica/manoscrittoBC.xml")//tei:body/tei:div[@type="pagina"][@n="2"]
    let $days := doc("/db/apps/tesiapplet/Codifica/manoscrittoBC.xml")//tei:body/tei:div[@type="pagina"][@n="2"]/tei:div[@type="day"]
    for $day in $days
        return 
            <div>
                    { for $e in $day/child::node() 
                    let $riga := $e/preceding-sibling::tei:lb[1]/@n
                        return if (name($e)!='lb') then <span data-riga="{$riga}" data-name="{name($e)}"> {string($e)}</span>
                        else    (<button class="bottoni_righe" onclick="freccia_riga({$riga})"><a href="#primaFoto">{string($riga)}</a></button>, 
                        <span data-riga="{$riga}" data-name="{name($e)}">{string($e)}</span>)
                        
                    }
            </div>
    
       
};

declare function app:titoloquery($node as node(), $model as map(*)){ (: map contiene tutti i dati dell'applicazione :)
    <h1>Interroga il documento!</h1>
};
declare function app:iconquery($node as node(), $model as map (*))
{
   <img src ="resources/images/query.png" class="sfondo" id="iconquery"/> 
   
 
};

declare function app:testoquery($node as node(), $model as map(*)){
    <div><p>
        Questa sezione dell'applicazione permette all'utente di eseguire una ricerca dei personaggi e dei luoghi menzionati nel Diario per ottenere maggiori informazioni a riguardo. I tre tipi di query si basano su una ricerca per nome della persona, cognome della persona e nome della località. Prova tu!
    </p></div>
};


(:  funzione della query per le perosne dal nome :)


declare
%templates:wrap
function app:query_form_persone($node as node(), $model as map(*), $query as xs:string?){
    let $no_query := not($query) (: dichiaro una viariabile $noq_Query che sia uguale alla vairbaile query negata (non query) :)
         return
            (: se non c'è una query non si genera nessun risultato (giusto un <br> per il layout :)
            if ($no_query) then
                <br />
            else
                for $nome in app:query_cerca_persone ($query)
                let $nota := $nome/../..//tei:note
                    return
                            <ul>
                                <li><span>{$nota/tei:persName[@n="query"]}</span>{$nota/tei:relation}</li>
                            </ul>
                
                    
                    
     
};

declare function app:query_cerca_persone( $query as xs:string){
    let $dati_persone := (
            doc("/db/apps/tesiapplet/Codifica/manoscrittoBC.xml" )/tei:TEI/tei:standOff/tei:listPerson/tei:person/tei:persName/tei:forename
     )
     let $persone_nomi := $dati_persone[ft:query(. ,$query)]
     for $hit in $persone_nomi
        return $hit
};

(: seconda funzione persone che cerca i cognomi :)
(: funzione per la query dei luoghi :)
declare
%templates:wrap
function app:query_cognome($node as node(), $model as map(*), $query as xs:string?){
    let $no_query := not($query) 
         return
            
            if ($no_query) then
                <br />
            else
                for $cognome in app:query_cerca_cognome ($query)
                let $nota := $cognome/../..//tei:note
                    return
                            <ul>
                                <li><span>{$nota/tei:persName[@n="query"]}</span>{$nota/tei:relation}</li>
                                
                            </ul>
};



declare function app:query_cerca_cognome( $query as xs:string){
    let $dati_persone := (
            doc("/db/apps/tesiapplet/Codifica/manoscrittoBC.xml" )//tei:person/tei:persName/tei:surname
     )
     
     let $persone_cogn:= $dati_persone[ft:query(. ,$query)]
     
     for $hit in $persone_cogn
        return $hit
};


(: funzione per la query dei luoghi :)
declare
%templates:wrap
function app:query_form_luoghi($node as node(), $model as map(*), $query as xs:string?){
    let $no_query := not($query) (: dichiaro una viariabile $noq_Query che sia uguale alla vairbaile query negata (non query) :)
         return
            (: se non c'è una query non si genera nessun risultato (giusto un <br> per il layout :)
            if ($no_query) then
                <br />
            else
                for $risultato in app:query_cerca_luoghi ($query)
                    return
                            <ul>
                                <li>Località:<span>{$risultato/tei:note//tei:placeName[@n="query"]}</span></li>
                                <li>Regione:{$risultato/tei:location/tei:region}</li>
                                <li>Paese:{$risultato/tei:location/tei:country}</li>
                                <li>Info:{$risultato/tei:note/tei:note[@xml:id="internal"]}</li>
                                
                            </ul>
     
};


declare function app:query_cerca_luoghi($query as xs:string){

    let $dati_luoghi:= (
            doc("/db/apps/tesiapplet/Codifica/manoscrittoBC.xml" )/tei:TEI/tei:standOff/tei:listPlace/tei:place
    )
    
    let $risult_luoghi := $dati_luoghi[ft:query(. ,$query)]
     
    for $hit in $risult_luoghi
        return $hit
};

(: PAGINA DELLA QUERY FUZZY----------------------------------------- :)
declare function app:titoloqueryfuzzy($node as node(), $model as map(*)){ (: map contiene tutti i dati dell'applicazione :)
    <h1>Svolgi una ricerca Fuzzy suoi luoghi</h1>
};

declare function app:testoqueryfuzzy($node as node(), $model as map(*)){
    <div><p>
        Cos'è la ricerca Fuzzy?
        La ricerca Fuzzy è un metodo più specifico più versatile di svolgere una ricerca. 
        Ad esempio, in una ricerca rigida, un utente può inserire una parola come "animale". Mentre la ricerca rigida cercherà soloistanze
        di "animale", una ricerca fuzzy aggiungerà la forma plurale, "animali" o altre ricerche simili termini o può cercare risultati
        errati o punteggiati in modo diverso.
    </p></div>
};


(: funzione per la query dei luoghi fuzzy :)
declare
%templates:wrap
function app:query_form_fuzzy($node as node(), $model as map(*), $query as xs:string?){
    let $no_query := not($query)
         return
            if ($no_query) then
                <br />
            else
                for $risultato in app:query_cerca_fuzzy ($query)
                    return
                            <ul> <div id="forse_cercavi_p">Forse cercavi...</div>
                                <br/><li>Località:<span>{$risultato/../tei:note//tei:placeName[@n="query"]}</span></li>
                                <li>Regione:{$risultato/../tei:location/tei:region}</li>
                                <li>Paese:{$risultato/../tei:location/tei:country}</li>
                                <li>Info:{$risultato/../tei:note/tei:note[@xml:id="internal"]}</li>
                                
                            </ul>
     
};


declare function app:query_cerca_fuzzy($query as xs:string){
    let $query :=
    <query>
    <fuzzy min-similarity="0.6">{$query}</fuzzy> <!--parametro di similarità-->
    </query>
    let $dati_luoghi:= 
            doc("/db/apps/tesiapplet/Codifica/manoscrittoBC.xml" )/tei:TEI/tei:standOff/tei:listPlace/tei:place/tei:placeName
    let $risult_luoghi := $dati_luoghi[ft:query(.,$query)]
     
    for $hit in $risult_luoghi
        return $hit
};


(: FUNZIONI PAGINA LUOGHI ......................................................................................................:)

declare function app:luoghititolo($node as node(), $model as map (*))
{
    <div class="titoli_classe"><h1>I luoghi della deportazione</h1></div>
};

declare function app:iconluoghi($node as node(), $model as map (*))
{
   <img src ="resources/images/places.png" class="sfondo" id="icon"/> 
   
 
};
declare function app:paragrafoluoghi($node as node(), $model as map (*))
{
    <p> Nel Diario Bruno descrive le tappe del suo viaggio verso la Germania, citando in particolare le località dell'alta Toscana. dell'Emilia Romagna ed i territori più a sud dell'Austria.</p>

};

(:  funzione che estrae la lista dei luoghi dalla parte finale di listPlace:)

declare function app:luoghilista($node as node(), $model as map(*)) {
    for $place in doc("/db/apps/tesiapplet/Codifica/manoscrittoBC.xml")//tei:listPlace//tei:place
    return 
    <ul>
    {for $l in $place
        return 
            <li>
                        
                         {$place}
                         <a href="{$l/tei:population/@href/string()}">Scopri di più su {$place/tei:placeName}
                         <i class="bi bi-search"></i></a> 
                         <br/>
                         La località è citata da Bruno a riga {$place/@n/string()} di {$place/@facs/string()}
            </li>
    }
    </ul>
    
                
            
};

declare function app:sottotitololuoghi($node as node(), $model as map (*))
{
    <h2>L'itinerario</h2>

};

(:  funzione che mostra immagine della mappa con itinerario:)

declare function app:mappa($node as node(), $model as map(*)){
    <img src="resources/images/img_luoghi_map.jpg" id="mappa" alt="mappa"/>
    
  
};

declare function app:testomappa($node as node(), $model as map(*)){
    <h3>Guarda su Google Maps</h3>

};

declare function app:mappa2($node as node(), $model as map(*)){
    <script type="text/javascript" src="resources/scripts/maps.js"/>
};



(: FUNZIONI PAGINA PERSONE ......................................................................................................:)

declare function app:personetitolo($node as node(), $model as map (*))
{
    <div class="titoli_classe"><h1>I personaggi del diario</h1></div>
    
};


declare function app:iconpersone($node as node(), $model as map (*))
{
   <img src ="resources/images/personal-information.png" class="sfondo" id="icon"/> 
   
 
};


declare function app:personetesto($node as node(), $model as map (*))
{
    <p>Di seguito sono riportati i nomi delle persone che Bruno Cimoli ha incontrato durante il viaggio e di cui fornisce qualche breve generalità. Purtroppo non è stato possibile, a causa della mancanza degli altri fogli del manoscritto, risalire alla storia di queste persone; nonostante ciò, è quantomeno necessario riportare almeno i loro nomi.</p>
};

(: funzione che restituisce persone dalla lista listPerson :)

declare function app:people($node as node(), $model as map(*)) {
    for $people in doc("/db/apps/tesiapplet/Codifica/manoscrittoBC.xml")//tei:listPerson//tei:person
                return 
                    <ul>
                        <li>
                            {$people}
                        </li>
                    </ul>
};

(: FUNZIONI PAGINA TERMINI ......................................................................................................:)

declare function app:terminititolo($node as node(), $model as map (*))
{
    <div class="titoli_classe"><h1>Termini tecnici</h1></div>
};

declare function app:icontermini($node as node(), $model as map (*))
{
   <img src ="resources/images/contract.png" class="sfondo" id="icon"/> 
   
 
};

(: funzoone che fa comparire i termini e fa riferimento al link tramite l'attributo source :)
declare function app:terminilista($node as node(), $model as map(*)) {
    for $terms in doc("/db/apps/tesiapplet/Codifica/manoscrittoBC.xml")//tei:list/tei:label
        for $l in $terms
             return 
                <ul>
                    <li> 
                         {$terms//tei:term}
                         {$terms//tei:gloss}
                         <a href="{$l//tei:gloss/@source/string()}">Scopri di più su {$l/tei:term}<i class="bi bi-search"></i></a>
                         
                    </li>
                </ul>
};

(: FUNZIONI PAGINA LESSICO ......................................................................................................:)
declare function app:lessicotitolo($node as node(), $model as map (*))
{
    <div class="titoli_classe"><h1>Il lessico del diario</h1></div>

};

declare function app:iconlessico($node as node(), $model as map (*))
{
   <img src ="resources/images/dictionary.png" class="sfondo" id="icon"/> 
   
 
};


declare function app:lessicotesto($node as node(), $model as map (*))
{
    <p>Nella sezione sottostante è riportato tutto il vocabolario del manoscritto del diario di Bruno Cimoli.
        Ho utilizzato alcune funzioni per tokenizzare gli enunciati, per normalizzare le parole e ridurre gli elementi superflui come apostrofi, virgole e punti.
    </p>
};

declare function app:indice($node as node(), $model as map (*))
{
    <h2>Indice delle parole</h2>

};

(: funzione per analisi del lessico :)
declare
function app:e_enunciato_aggiungi_spazio($enunciato) { 
    for $e in $enunciato/node()
    return ( $e, " ")
};

(:viene ripulito il testo tramite delle funzioni standard messe a disposizione da xquery  :)

declare
%templates:wrap
function app:lessico($node as node(), $model as map (*)){
    let $parole := doc ("/db/apps/tesiapplet/Codifica/manoscrittoBC.xml")//tei:body (:  suddivide il testo nel body:)
    
    let $parole_con_spazio := ( 
    for $enunciato in $parole (:  enunciato dichiarato precedentemente scandisce parole:)
    let $e_spaziati := app:e_enunciato_aggiungi_spazio($enunciato) (: ogni elemento di enunciato è un e con lo spazio:)
    return ( $e_spaziati, " ")
    )
    let $dati_testuali := data($parole_con_spazio) (:  parole con spazio è l'insieme di tutte le e :)
       
    let $stringa_normalizzata := normalize-space(string-join($dati_testuali)) (: si normalizzano le parole :)
    let $minuscolo := lower-case($stringa_normalizzata) (: trasforma in minuscolo :)
    let $no_caratteri_speciali := replace($minuscolo, '\.|,|!|\?|"|:|;|”', '') (: elimina i caratteri speciali :)
    let $cambio_apostrofo_spazio := replace($no_caratteri_speciali, "'", ' ')
    let $stringa_ripulita := normalize-space(string-join($cambio_apostrofo_spazio)) (: funzione di normalizzazione degli spazi anche per le parole che sono state ripulite e a cui è stato aggiunto lo spazio :)
    let $sequenza_parole := tokenize($stringa_ripulita, " ") (: tokenizzazione della stringa ripulita :)
    let $vocabolario := distinct-values($sequenza_parole) (:  con distinct values possiamo calcolare solo le parole tipo:)
    let $corpus := count($sequenza_parole) (:  otteniamo così, invece, la dimensione il corpus:)
    let $dim_vocab := count($vocabolario) (:  contiamo le parole del vocabolario:)
    let $parolesorted := sort($vocabolario) (: vengono restituite in ordine grazie alla funzione sort :)
    for $s in $parolesorted (:  vengono scandite per svolgere le operazioni di calcolo delle frequenze assolute e relative:)
    return
        let $fabs := count($sequenza_parole[. = $s])
        let $frel := round-half-to-even(($fabs div $corpus) * 100, 3)
        
        return 
        <li class="parole"> 
            {$s}  

            <div class="stats">
                <ul>
                    <li>Frequenza assoluta: {$fabs}</li>
                    <li>Frequenza relativa: {$frel} % </li>
                </ul>
            </div>
        </li>  (:  funzione che restituisce le frequenze asslute delle parole :)


        
};

(: stessa funzione utilizzata per restituire i dati realtivi al coprus e al vocabolario :)

declare
%templates:wrap
function app:statistiche($node as node(), $model as map (*)){
    let $parole := doc ("/db/apps/tesiapplet/Codifica/manoscrittoBC.xml")//tei:body
    
    let $parole_con_spazio := (
    for $enunciato in $parole
    let $e_spaziati := app:e_enunciato_aggiungi_spazio($enunciato)
    return ( $e_spaziati, " ")
    )
    let $dati_testuali := data($parole_con_spazio)
       
    let $stringa_normalizzata := normalize-space(string-join($dati_testuali))
    let $minuscolo := lower-case($stringa_normalizzata) (: trasforma in minuscolo i dati :)
    let $no_caratteri_speciali := replace($minuscolo, '\.|,|!|\?|"|:|;|”', '') (: elimina i caratteri speciali :)
    let $cambio_apostrofo_spazio := replace($no_caratteri_speciali, "'", ' ')
    let $stringa_ripulita := normalize-space(string-join($cambio_apostrofo_spazio))
    let $sequenza_parole := tokenize($stringa_ripulita, " ")
    let $vocabolario := distinct-values($sequenza_parole)
    let $corpus := count($sequenza_parole)
    let $nvoc :=count($vocabolario)
    return
        <ul>
        <li>Parole totali: {$corpus}</li>
        <li>Vocabolario: {$nvoc}</li>
        </ul>
};

(:  footer :)
declare function app:footer($node as node(), $model as map (*))
{
   <div id="footer_text">Progetto di Greta Montera, coordinato da Marina Riccucci e Angelo Mario Del Grosso.<br/>
       Università di Pisa. <br/>
       Anno scolastico 2022-2023
   </div>
   
 
};




