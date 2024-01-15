xquery version "3.1";

(:~ Applicazione Tesi - Ida Marcheria.
 :
 : @author Erika Deboni
 : @version 1.0.0
 : @see http://exist-db.org
 :)

(: Module for app-specific template functions :)
module namespace app="http://exist-db.org/apps/marcheria/templates";
import module namespace templates="http://exist-db.org/xquery/html-templating";
import module namespace lib="http://exist-db.org/xquery/html-templating/lib";
import module namespace config="http://exist-db.org/apps/marcheria/config" at "config.xqm";

(: declare necessario per usare gli elementi tei nell'xml :)
declare namespace tei = 'http://www.tei-c.org/ns/1.0';

(:  funzioni utilizzate per la trasformazione del testo :)

(: ottiene la lista degli enunciati del documento e la inserisce in model come "enunciati" :)
(: aggiungo al modello $model, anche la timeline di cambio parlante che sarà usata successivamente per visualizzare 
 : i tempi di inizio di ogni enunciato, dalla funzione stampa-tempo-enunciato
:)
declare 
function app:lista-enunciati($node as node(), $model as map(*)) as map(*) {
    let $enunciati := doc( $config:app-root || "/xml/ida_marcheria.xml" )//tei:u
    let $timeline_tlp := doc( $config:app-root || "/xml/ida_marcheria.xml" )/tei:TEI/tei:standOff/tei:timeline[@xml:id="tlp"]
    return
        map 
        { 
            "enunciati": $enunciati,
            "timeline_tlp" : $timeline_tlp
        }
};

(: formatta i figli del nodo enunciato :)     
declare
function app:gestisci-figli-enunciato($node as node(), $model as map(*)) {
    let $enunciato := $model("enunciato")
    (: per ogni nodo figlio :)
    let $contenuto_testo := data($enunciato)
    let $lunghezza_testo_contenuto := string-length(normalize-space($contenuto_testo))
    for $nodo_figlio in $enunciato/node()
    let $localName := $nodo_figlio/local-name()
    return
        if ($localName = "") then 
            <span class="testo_default"> { data($nodo_figlio) } </span>
            
        else if ($localName = "gap") then
            
            (: se la lunghezza dell'enunciato è 0 allora si lascia visibile :)
            if ($lunghezza_testo_contenuto = 0) then 
                <span class="gap_visibile">TESTO NON UDIBILE</span>
            else
                <span class="gap">TESTO NON UDIBILE</span> 
                    
        else if ($localName = "vocal") then
                
            (: se la lunghezza dell'enunciato è uguale alla lunghezza del vocal, si lascia visibile :)
            if ($lunghezza_testo_contenuto = string-length(normalize-space(data($nodo_figlio)))) then 
                <span class="vocal_visibile">({ app:gestisci-figlio($nodo_figlio, $lunghezza_testo_contenuto) })</span>
            else
                <span class="vocal">({ app:gestisci-figlio($nodo_figlio, $lunghezza_testo_contenuto) })</span> 

        else if ($localName = "del") then
                
            (: se la lunghezza dell'enunciato è uguale alla lunghezza del del, si lascia visibile :)
            if ($lunghezza_testo_contenuto = string-length(normalize-space(data($nodo_figlio)))) then 
                <span class="del_visibile">{ app:gestisci-figlio($nodo_figlio, $lunghezza_testo_contenuto) }</span>
            else
                <span class="del">{ app:gestisci-figlio($nodo_figlio, $lunghezza_testo_contenuto) }</span> 
                
        else
            <span class="{ $localName }"> { app:gestisci-figlio($nodo_figlio, $lunghezza_testo_contenuto) } </span>
};

(: formatta ricorsivamente i sotto-figli del nodo enunciato :) 
declare
function app:gestisci-figlio($nodo_corrente as node(), $lunghezza_testo_contenuto as xs:integer) {
    for $nodo_figlio in $nodo_corrente/node()
        let $localName := $nodo_figlio/local-name()
        return 
            if ($localName = "") then 
                <span class="testo_default"> { data($nodo_figlio) } </span>
                
            else if ($localName = "vocal") then
                
                (: se la lunghezza dell'enunciato è uguale alla lunghezza del vocal, si lascia visibile :)
                if ($lunghezza_testo_contenuto = string-length(normalize-space(data($nodo_figlio)))) then 
                    <span class="vocal_visibile">({ app:gestisci-figlio($nodo_figlio, $lunghezza_testo_contenuto) })</span>
                else
                    <span class="vocal">({ app:gestisci-figlio($nodo_figlio, $lunghezza_testo_contenuto) })</span> 
            else
                <span class="{ $localName }"> { app:gestisci-figlio($nodo_figlio, $lunghezza_testo_contenuto) } </span>
};

(: formatta la sigla dell'enunciato :)
declare
%templates:wrap
function app:stampa-sigla($node as node(), $model as map(*)) {
    let $enunciato := $model("enunciato")
    let $formattato := normalize-space( 
        string-join( 
            (
            tokenize($enunciato/@who, "#")[2], 
            string(":"))))
        return $formattato
}; 

(: conta gli enunciati e restituisce il numero :)
declare 
function app:conta-enunciati($node as node(), $model as map(*)) as xs:integer {
    count($model("enunciati"))
};

(: stampa il tempo (di inizio) relativo a un enunciato, se richiesto (cioè se viene passato il parametro mostra_tempo=yes) :)
declare
%templates:wrap
function app:stampa-tempo-enunciato($node as node(), $model as map(*), $mostra_tempo as xs:string?) {
    let $no_tempo := not($mostra_tempo) or ($mostra_tempo != "yes")
    return
        if ($no_tempo) then
            ""
        else
            let $enunciato := $model("enunciato")
            let $timeline := $model("timeline_tlp")
            
            (: si recupera l'attributo synch dall'enunciato e si rimuove il # :)
            let $synch := tokenize($enunciato/@synch, "#")[2]
            
            (: si recupera l'elemento when sincronizzato all'enunciato, dalla timeline del cambio parlante  :)
            let $when := $timeline/tei:when[@xml:id=$synch]
        
            return data($when/@absolute)
}; 

(: 
 : funzione di gestione del bottone mostra / nascondi minutaggio
 : mostra un bottone con opportuno messaggio a seconda che si stia mostrando il minutaggio o meno
 : la funzionalita di passaggio da una modalita all'altra è stata implementata con una form
 : con campo hidden "mostra_tempo" opportunamente settato (o meno)
:)
declare
function app:bottone-gestione-minutaggio($node as node(), $model as map(*), $mostra_tempo as xs:string?) {
    let $no_tempo := not($mostra_tempo) or ($mostra_tempo != "yes")
    return
        if ($no_tempo) then
            <form style="margin:0;" method="GET">
                <input type="hidden" name="mostra_tempo" value="yes"/>
                <button type="submit" class="bottone" id="bottone_minutaggio">Mostra Minutaggio</button>
            </form>
            
        else
            <form style="margin:0;" method="GET">
                <!--input type="hidden" name="mostra_tempo" value="no"/-->
                <button type="submit" class="bottone" id="bottone_minutaggio">Nascondi Minutaggio</button>
            </form>
};


declare
%templates:wrap
function app:stampa-titolo1($node as node(), $model as map(*)) {
    let $titolo := doc( $config:app-root || "/xml/ida_marcheria.xml" )/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt
    return data($titolo/tei:title[@type='main'])
};

declare
%templates:wrap
function app:stampa-titolo2($node as node(), $model as map(*)) {
    let $titolo := doc( $config:app-root || "/xml/ida_marcheria.xml" )/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt
    return data($titolo/tei:title[@type='sub'])
};

declare
%templates:wrap
function app:stampa-edition($node as node(), $model as map(*)) {
    let $edition := doc( $config:app-root || "/xml/ida_marcheria.xml" )/tei:TEI/tei:teiHeader/tei:fileDesc/tei:editionStmt
    return data($edition/tei:edition)
};

declare
%templates:wrap
function app:stampa-encoding($node as node(), $model as map(*)) {
    let $encoding := doc( $config:app-root || "/xml/ida_marcheria.xml" )/tei:TEI/tei:teiHeader/tei:fileDesc/tei:editionStmt/tei:respStmt
    return data($encoding)
};



declare
%templates:wrap
function app:stampa-resp($node as node(), $model as map(*)) {
    let $resp := doc( $config:app-root || "/xml/ida_marcheria.xml" )/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:recordingStmt/tei:recording/tei:respStmt
    return data($resp/tei:resp)
};

declare
%templates:wrap
function app:stampa-name($node as node(), $model as map(*)) {
    let $name := doc( $config:app-root || "/xml/ida_marcheria.xml" )/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:recordingStmt/tei:recording/tei:respStmt
    return data($name/tei:name)
};

declare
%templates:wrap
function app:stampa-note($node as node(), $model as map(*)) {
    let $note := doc( $config:app-root || "/xml/ida_marcheria.xml" )/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:recordingStmt/tei:recording/tei:respStmt
    return data($note/tei:note)
};

declare
%templates:wrap
function app:stampa-marcatura($node as node(), $model as map(*)) {
    let $marcatura := doc( $config:app-root || "/xml/ida_marcheria.xml" )/tei:TEI/tei:teiHeader
    return data($marcatura/tei:encodingDesc)
};


(: forse si puo buttare :)
declare
%templates:wrap
function app:stampa-enunciato($node as node(), $model as map(*)) {
    let $enunciato := $model("enunciato")|| string(" -")     
        return $enunciato
};

declare
%templates:wrap
function app:stampa-listOrg($node as node(), $model as map(*)) {
    let $listOrg := doc( $config:app-root || "/xml/ida_marcheria.xml" )/tei:TEI/tei:text/tei:back/tei:listOrg/tei:org/tei:orgName
    for $orgName in $listOrg
    order by $orgName/@xml:id
     return <p><a href="{data($orgName/@ref)}" >{data($orgName)}</a></p>
};

declare
%templates:wrap
function app:stampa-listPerson($node as node(), $model as map(*)) {
    for $person in doc( $config:app-root || "/xml/ida_marcheria.xml" )/tei:TEI/tei:text/tei:back/tei:listPerson/tei:person
    order by $person/@xml:id
    return <p><a href="{data($person/tei:persName/@ref)}" >{data($person/tei:persName)}</a></p>  
};

declare
%templates:wrap
function app:stampa-listPlace($node as node(), $model as map(*)) {
    let $listPlace := doc( $config:app-root || "/xml/ida_marcheria.xml" )/tei:TEI/tei:text/tei:back/tei:listPlace/tei:place/tei:placeName  
    for $place in $listPlace
    order by $place/@xml:id
     return <p><a href="{data($place/@ref)}" >{data($place)}</a></p>    
};

declare
%templates:wrap
function app:stampa-marcheria($node as node(), $model as map(*)) {
    let $marcheria := doc( $config:app-root || "/xml/ida_marcheria.xml" )/tei:TEI/tei:teiHeader/tei:profileDesc/tei:particDesc/tei:listPerson/tei:person[@xml:id='MARCHERIA']/tei:persName
    for $ida in $marcheria 
     return <p><a href="{data($ida/@ref)}" > {data($ida)}</a></p> 
};

declare
%templates:wrap
function app:stampa-segre($node as node(), $model as map(*)) {
    let $segre := doc( $config:app-root || "/xml/ida_marcheria.xml" )/tei:TEI/tei:teiHeader/tei:profileDesc/tei:particDesc/tei:listPerson/tei:person[@xml:id='AS']/tei:persName
    for $anna in $segre 
     return <p><a href="{data($anna/@ref)}" > {data($anna)}</a></p> 
};

declare
%templates:wrap
function app:stampa-pavoncello($node as node(), $model as map(*)) {
    let $pavoncello := doc( $config:app-root || "/xml/ida_marcheria.xml" )/tei:TEI/tei:teiHeader/tei:profileDesc/tei:particDesc/tei:listPerson/tei:person[@xml:id='GP']/tei:persName
    for $gloria in $pavoncello 
     return <p><a href="{data($gloria/@ref)}" > {data($gloria)}</a></p>
};

declare
%templates:wrap
function app:stampa-parte-riassunto($node as node(), $model as map(*), $titolo as xs:string, $idtimeline as xs:string, $idparte as xs:string) {
    
    let $idparte_cancelletto := "#" || $idparte
    let $parte := doc( $config:app-root || "/xml/ida_marcheria.xml" )/tei:TEI/tei:teiHeader/tei:profileDesc/tei:abstract/tei:ab/tei:list/tei:item[@synch=$idparte_cancelletto]
    let $evento := doc( $config:app-root || "/xml/ida_marcheria.xml" )/tei:TEI/tei:standOff/tei:timeline[@xml:id=$idtimeline]//tei:when[@xml:id=$idparte]
    
    return 
        <div>
            <div class="separatore">{ $titolo } (al minuto { data($evento/@absolute) })</div>
            <div>{ $parte }</div>
        </div>
};

declare
%templates:wrap
function app:protagoniste($node as node(), $model as map(*)) {
    let $protagoniste := doc( $config:app-root || "/xml/ida_marcheria.xml" )/tei:TEI/tei:teiHeader/tei:profileDesc/tei:particDesc/tei:listPerson/tei:person/tei:persName
    for $protagonista in $protagoniste
    return <p><a href="{data($protagonista/@ref)}" > {data($protagonista)}</a></p>
};                                                                                                                                                                          

declare
%templates:wrap
function app:shlomo($node as node(), $model as map(*)) {
    let $shlomo := doc( $config:app-root || "/xml/ida_marcheria.xml" )/tei:TEI/tei:text/tei:back/tei:listPerson/tei:person[@xml:id="SV"]/tei:persName
    return <p><a href="{data($shlomo/@ref)}" > {data($shlomo)}</a></p>
};

declare
%templates:wrap
function app:stella($node as node(), $model as map(*)) {
    let $stella := doc( $config:app-root || "/xml/ida_marcheria.xml" )/tei:TEI/tei:text/tei:back/tei:listPerson/tei:person[@xml:id="Stella"]/tei:persName
    return <p><a href="{data($stella/@ref)}" > {data($stella)}</a></p>
};

declare
%templates:wrap
function app:piero($node as node(), $model as map(*)) {
    let $piero := doc( $config:app-root || "/xml/ida_marcheria.xml" )/tei:TEI/tei:text/tei:back/tei:listPerson/tei:person[@xml:id="PT"]/tei:persName
    return <p><a href="{data($piero/@ref)}" > {data($piero)}</a></p>
};

declare
%templates:wrap
function app:settimia($node as node(), $model as map(*)) {
    let $settimia := doc( $config:app-root || "/xml/ida_marcheria.xml" )/tei:TEI/tei:text/tei:back/tei:listPerson/tei:person[@xml:id="SS"]/tei:persName
    return <p><a href="{data($settimia/@ref)}" > {data($settimia)}</a></p>
};

declare
%templates:wrap
function app:nedo($node as node(), $model as map(*)) {
    let $nedo := doc( $config:app-root || "/xml/ida_marcheria.xml" )/tei:TEI/tei:text/tei:back/tei:listPerson/tei:person[@xml:id="NF"]/tei:persName
    return <p><a href="{data($nedo/@ref)}" > {data($nedo)}</a></p>
};

(: funzione per inserire i punti di interesse sulla mappa:
 : la mappa leaflet è gestita con il codice js, e necessita delle informazioni per creare i punti di interesse,
 : che però si trovano sull'xml (tag place in listPlace)
 : per passare queste informazioni, ho scelto di creare un div nascosto con id="punti_mappa", per il solo passaggio dati,
 : che viene popolato da questa stessa funzione.
 : piu precisamente per ogni punto di interesse, si aggiunge un div figlio che a sua volta contiene:
 : - un primo div con il nome in chiaro del punto
 : - un secondo, col link presente nell'attributo @ref
 : - un terzo, col contenuto del suo nodo location/geo, cioè latitudine e longitudine 
 : in questo modo il codice js, accede con getElementiById al div nascosto e vi recupera tutte le informazioni necessarie
 :)
declare
%templates:wrap
function app:punti_mappa($node as node(), $model as map(*)) {
    for $place in doc( $config:app-root || "/xml/ida_marcheria.xml" )/tei:TEI/tei:text/tei:back/tei:listPlace//tei:place
    return 
        <div>
            <div>{ data($place/tei:placeName) }</div>
            <div>{ data($place/tei:placeName/@ref) }</div>
            <div>{ data($place/tei:location/tei:geo) }</div>
        </div>
};


(: query statistiche su pause :)

declare
function app:secondi_pause_non_short() {
    let $elementi_pause := doc( $config:app-root || "/xml/ida_marcheria.xml" )/tei:TEI/tei:text/tei:body//tei:pause
    let $sequenza_secondi := (
        for $elemento_pause in $elementi_pause
        where $elemento_pause/@type != "short"
        let $duration := xs:duration($elemento_pause/@dur)
        return 
            seconds-from-duration($duration) + minutes-from-duration($duration) * 60 + hours-from-duration($duration) * 3600
    )
    return $sequenza_secondi
};

declare
function app:secondi_pause() {
    let $elementi_pause := doc( $config:app-root || "/xml/ida_marcheria.xml" )/tei:TEI/tei:text/tei:body//tei:pause
    let $sequenza_secondi := (
        for $elemento_pause in $elementi_pause
        return
            if ($elemento_pause[@dur]) then
                seconds-from-duration(xs:duration($elemento_pause/@dur)) + minutes-from-duration(xs:duration($elemento_pause/@dur)) * 60 + hours-from-duration(xs:duration($elemento_pause/@dur)) * 3600
            else
              2.5 (: media delle pause short, cioe che vanno da 0 a 4.9 secondi :)
    )
    return $sequenza_secondi
};

declare
function app:stampa_durata_leggibile($secondi) {
    
    (: si trasformano i secondi in duration cosi che siano gia suddivisi i minuti ore ecc :)
    let $duration := xs:dayTimeDuration("PT" || format-number( $secondi , ".00") || "S")
    
    (: ottengo le componenti separate :)
    let $sec := seconds-from-duration($duration)
    let $min := minutes-from-duration($duration)
    let $hrs := hours-from-duration($duration)
    
    (: si stampa un testo formattato a seconda se ci siano anche ore e minuti diversi da 0 :)
    return 
        if($hrs = 0 and $min = 0) then
            if($sec = 0) then
                "sotto il secondo"
            else
                $sec || " secondi"
        else if($hrs = 0) then
            $min || " minuti e " || $sec || " secondi"
        else
            $hrs || " ore, " || $min || " minuti e " || $sec || " secondi"
};

declare
%templates:wrap
function app:media_secondi_pause($node as node(), $model as map(*), $opzioni as xs:string) {
    let $variabile_inutile := 0
    return
        if ($opzioni = "tutto") then 
            app:stampa_durata_leggibile( avg(app:secondi_pause()) )
        else
            app:stampa_durata_leggibile( avg(app:secondi_pause_non_short()) )
        
};

declare
%templates:wrap
function app:somma_secondi_pause($node as node(), $model as map(*), $opzioni as xs:string) {
    let $variabile_inutile := 0
    return
        if ($opzioni = "tutto") then 
            app:stampa_durata_leggibile( sum(app:secondi_pause()) )
        else
            app:stampa_durata_leggibile( sum(app:secondi_pause_non_short()) )
        
};

declare
%templates:wrap
function app:conta_pause($node as node(), $model as map(*), $opzioni as xs:string) {
    let $variabile_inutile := 0
    return
        if ($opzioni = "tutto") then 
            count(app:secondi_pause())
        else
            count(app:secondi_pause_non_short())
        
};

declare
%templates:wrap
function app:max_pause($node as node(), $model as map(*), $opzioni as xs:string) {
    let $variabile_inutile := 0
    return
        if ($opzioni = "tutto") then 
            app:stampa_durata_leggibile( max(app:secondi_pause()) )
        else
            app:stampa_durata_leggibile( max(app:secondi_pause_non_short()) )
        
};

(: statistiche timeline cambio parlante :)

(: ottengo who dell'enunciato, a partire dal synch associato che è in timeline :)
declare
function app:id_parlante_da_synch($synch) {
    let $id_u := tokenize($synch, "#")[2]
    let $enunciato := doc( $config:app-root || "/xml/ida_marcheria.xml" )/tei:TEI/tei:text/tei:body//tei:u[@xml:id = $id_u]
    return data($enunciato/@who)
};

(:  ottengo la lista delle durate dello specifico parlante :)
declare
function app:durate_u_da_cambi_parlante($parlante) {
    let $eventi := doc( $config:app-root || "/xml/ida_marcheria.xml" )/tei:TEI/tei:standOff/tei:timeline[@xml:id = "tlp"]//tei:when
    for $evento at $i in $eventi
    where $i > 1 (: si esclude il primo elemento perche non ha un elemento precedente :)
    let $i_prec := $i - 1
    let $id_parlante := "#" || $parlante
    return
        if (app:id_parlante_da_synch(data($eventi[$i_prec]/@synch)) = $id_parlante ) then
            xs:time($evento/@absolute) - xs:time($eventi[$i_prec]/@absolute)
        else
            ()
};

(:  trasformo lista delle duration in secondi (per usare le funzioni avg, max ecc) :)
declare
function app:durate_in_secondi($lista_duration) {
    for $duration in $lista_duration
    return
        seconds-from-duration($duration) + minutes-from-duration($duration) * 60 + hours-from-duration($duration) * 3600
};

declare
function app:calcolo_durata_media($id_parlante) {
    let $lista_duration := app:durate_u_da_cambi_parlante($id_parlante)
    let $lista_secondi := app:durate_in_secondi($lista_duration)
    let $durata_media_secondi := avg($lista_secondi)
    return
        app:stampa_durata_leggibile($durata_media_secondi)
};

declare
function app:calcolo_durata_massima($id_parlante) {
    let $lista_duration := app:durate_u_da_cambi_parlante($id_parlante)
    let $lista_secondi := app:durate_in_secondi($lista_duration)
    let $durata_massima_secondi := max($lista_secondi)
    return
        app:stampa_durata_leggibile($durata_massima_secondi)
};

declare
function app:calcolo_durata_minima($id_parlante) {
    let $lista_duration := app:durate_u_da_cambi_parlante($id_parlante)
    let $lista_secondi := app:durate_in_secondi($lista_duration)
    let $durata_minima_secondi := min($lista_secondi)
    return
        app:stampa_durata_leggibile($durata_minima_secondi)
};

declare
function app:nome_persona_da_id($id_persona) {
    let $dati_persone := (
            doc( $config:app-root || "/xml/ida_marcheria.xml" )/tei:TEI/tei:text/tei:back/tei:listPerson//tei:person,
            doc( $config:app-root || "/xml/ida_marcheria.xml" )/tei:TEI/tei:teiHeader/tei:profileDesc/tei:particDesc/tei:listPerson//tei:person
        )
    for $persona in $dati_persone
    where $persona/@xml:id = $id_persona
    return data($persona)
};

declare
%templates:wrap
function app:calcolo_lunghezze_frasi($node as node(), $model as map(*), $parlante as xs:string?) {
    let $no_parlante := not($parlante)
    return
        if ($no_parlante) then
            <br />
        else
            <table class="table table-striped table-borderless">
                <thead>
                    <tr><th colspan="2" scope="col">Statistiche per { app:nome_persona_da_id($parlante) }:</th></tr>
                </thead>
                <tbody>
                    <tr>
                        <th scope="col">Durata media</th>
                        <td>{ app:calcolo_durata_media($parlante) }</td>
                    </tr>
                    <tr>
                        <th scope="col">Durata massima</th>
                        <td>{ app:calcolo_durata_massima($parlante) }</td>
                    </tr>
                    <tr>
                        <th scope="col">Durata minima</th>
                        <td>{ app:calcolo_durata_minima($parlante) }</td>
                    </tr>
                </tbody>
            </table>
};




declare
%templates:wrap
function app:durate_enunciati_testimone($node as node(), $model as map(*)) {
    let $sequenza_ordinata := (
            for $enunciato in doc( $config:app-root || "/xml/ida_marcheria.xml" )/tei:TEI/tei:text/tei:body//tei:u[@who="#MARCHERIA"]
            let $durata := app:calcolo_durata_enunciato($enunciato)
            order by $durata
            return 
                <statistica>
                    <durata>{ $durata }</durata>
                    <enunciato>{ $enunciato }</enunciato>
                </statistica>
        )
    let $pos_max := count($sequenza_ordinata)
    return 
        <table class="table table-striped table-borderless">
            <thead>
                <tr><th colspan="3" scope="col" class="titolo_query">Statistiche su enunciati del testimone:</th></tr>
                <tr>
                    <th>Statistica</th>
                    <th>Durata</th>
                    <th>Enunciato</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <th>Durata minima</th>
                    <td class="td_durata_allargato">{ app:stampa_duration( $sequenza_ordinata[1]/durata ) }</td>
                    <td>{ data( $sequenza_ordinata[1]/enunciato ) }</td>
                </tr>
                <tr>
                    <th>Durata massima</th>
                    <td class="td_durata_allargato">{ app:stampa_duration( $sequenza_ordinata[$pos_max]/durata ) }</td>
                    <td>{ data( $sequenza_ordinata[$pos_max]/enunciato ) }</td>
                </tr>
            </tbody>
        </table>

};

(: 
 : funzione per la stampa in formato "leggibile" di una duration
 : creata a partire da stampa_durata_leggibile,
 : che invece lavora con imput il numero di secondi
:)
declare
function app:stampa_duration($duration) {
    
    (: ottengo le componenti separate :)
    let $sec := seconds-from-duration($duration)
    let $min := minutes-from-duration($duration)
    let $hrs := hours-from-duration($duration)
    
    (: si stampa un testo formattato a seconda se ci siano anche ore e minuti diversi da 0 :)
    return 
        if($hrs = 0 and $min = 0) then
            if($sec = 0) then
                "sotto il secondo"
            else
                $sec || " secondi"
        else if($hrs = 0) then
            $min || " minuti e " || $sec || " secondi"
        else
            $hrs || " ore, " || $min || " minuti e " || $sec || " secondi"
};

declare
function app:calcolo_durata_enunciato($enunciato) {
    
    (: ottengo la timeline tlp, che utilizzo per prendere i tempi, da absolute :)
    let $timeline := doc( $config:app-root || "/xml/ida_marcheria.xml" )/tei:TEI/tei:standOff//tei:timeline[@xml:id = "tlp"]
    
    (: ottengo il synch dell'enunciato e tolgo il # :)
    let $synch := tokenize($enunciato/@synch, "#")[2]
    
    (: ottengo il when relativo all'enunciato, nella timeline tlp :)
    let $when := $timeline//tei:when[@xml:id=$synch]
    
    (: a questo punto ho il tempo iniziale, lo ottengo da attributo absolute, e lo converto in xs:time :)
    let $tempo_iniziale := xs:time($when/@absolute)
    
    (: per ottenere il tempo finale, devo guardare il when "fratello successivo" :)
    let $when_successivo := $when/following-sibling::tei:when[1]
    
    (: ora ottengo il tempo finale dal when successivo :)
    let $tempo_finale := xs:time($when_successivo/@absolute)
    
    (: la duration si ottiene come differenza dei due tempi :)
    return $tempo_finale - $tempo_iniziale
};



(: funzione per ottenere il grafico di confronto tra i parlanti (tra chi ha parlato di piu) :)
declare
function app:grafico_durate_parlanti($node as node(), $model as map(*)) {
    
    let $lista_id_parlanti := ("MARCHERIA", "AS", "GP", "RDS", "MAIKELE", "NI", "VOCE_UOMO", "VOCE_DONNA", "NANNY")
    
    (: 
    ottengo i tempi, in secondi, delle durate totali per ogni parlante
    questi dati si usano per valorizzare il grafico
    :)
    let $lista_durate_secondi := (
        for $id_parlante in $lista_id_parlanti
        return app:durata_totale_parlante( $id_parlante )
    )

    (:
    ottengo le durate in testo leggibile da usare nelle label del grafico
    :)
    let $lista_durate_label := (
        for $durata_secondi in $lista_durate_secondi
        let $duration := xs:dayTimeDuration("PT" || format-number( $durata_secondi , ".00") || "S")
        return app:stampa_duration( $duration )
    )
    
    (:
    infine i nomi / descrizioni delle persone parlanti, per esteso
    :)
    
    
    
    let $lista_parlanti := (
        let $dati_persone := (
            doc( $config:app-root || "/xml/ida_marcheria.xml" )/tei:TEI/tei:text/tei:back/tei:listPerson//tei:person,
            doc( $config:app-root || "/xml/ida_marcheria.xml" )/tei:TEI/tei:teiHeader/tei:profileDesc/tei:particDesc/tei:listPerson//tei:person
        )
        for $id_parlante in $lista_id_parlanti
        let $persona := $dati_persone[@xml:id=$id_parlante]
        return normalize-space( data($persona) )
    )
    
    return 
        <div class="well">
            <p class="titolo_query">Grafico di confronto tempi dei parlanti</p>
            <p>Cliccare sulle etichette per visualizzare o nascondere la fetta di grafico relativa</p>
            <canvas id="graficoDurateParlanti" width="400" height="400"></canvas>
            <script>
            const ctx = document.getElementById('graficoDurateParlanti').getContext('2d');
            const graficoDurateParlanti = new Chart(ctx, {{
                type: 'pie',
                data: {{
                    labels: [
                    { 
                        for $parlante at $i in $lista_id_parlanti
                        let $nome_desc := $lista_parlanti[$i]
                        let $durata := $lista_durate_label[$i]
                        return "'" || $nome_desc || " (" || $durata || ")',"
                    }
                    ],
                    datasets: [{{
                        label: 'Tempi totali dei parlanti',
                        data: [
                        { 
                            for $secondi in $lista_durate_secondi
                            return $secondi || ","
                        }
                        ],
                        backgroundColor: [
                            'rgba(255, 99, 132, 0.2)',
                            'rgba(54, 162, 235, 0.2)',
                            'rgba(255, 206, 86, 0.2)',
                            'rgba(75, 192, 192, 0.2)',
                            'rgba(153, 102, 255, 0.2)',
                            'rgba(255, 159, 64, 0.2)',
                            'rgba(0, 0, 255, 0.2)',
                            'rgba(255, 127, 80, 0.2)',
                            'rgba(220, 20, 60, 0.2)'
                        ],
                        borderColor: [
                            'rgba(255, 99, 132, 1)',
                            'rgba(54, 162, 235, 1)',
                            'rgba(255, 206, 86, 1)',
                            'rgba(75, 192, 192, 1)',
                            'rgba(153, 102, 255, 1)',
                            'rgba(255, 159, 64, 1)',
                            'rgba(0, 0, 255, 1)',
                            'rgba(255, 127, 80, 1)',
                            'rgba(220, 20, 60, 1)'
                        ],
                        borderWidth: 1,
                        hoverOffset: 24
                    }}]
                }},
            }});
            </script>
        </div>
};





declare
function app:durata_totale_parlante($id_parlante) {
    let $durate_enunciati := (
        for $enunciato in doc( $config:app-root || "/xml/ida_marcheria.xml" )/tei:TEI/tei:text/tei:body//tei:u[@who="#" || $id_parlante]
        let $durata := app:calcolo_durata_enunciato($enunciato)
        return 
            $durata
    )
    let $durate_secondi := app:durate_in_secondi($durate_enunciati)
    let $totale_secondi := sum($durate_secondi)
    return $totale_secondi
};





























(: form interattiva con query : ricerca persone (testo nome cognome e descrizioni) :)

declare
%templates:wrap
function app:query_form_persone($node as node(), $model as map(*), $query as xs:string?, $fuzzy as xs:string?) {
    let $no_query := not($query)
    return
        if ($no_query) then
            <br />
        else
            <table class="table table-striped table-borderless">
                <thead>
                    <tr><th colspan="4" scope="col">Risultati per "{ $query }":</th></tr>
                    <tr>
                        <th scope="col">Nome</th>
                        <th scope="col">Cognome</th>
                        <th scope="col">Ruolo</th>
                        <th scope="col"></th>
                    </tr>
                </thead>
                <tbody>
                    {
                        for $risultato in app:query_cerca($query, $fuzzy)
                        return 
                            <tr>
                                <td>{ data($risultato/tei:persName/tei:forename) }</td>
                                <td>{ data($risultato/tei:persName/tei:surname) }</td>
                                <td>{ data($risultato/tei:persName/tei:roleName) }</td>
                                <td><a href="{ data($risultato/tei:persName/@ref) }">Info</a></td>
                            </tr>
                    }
                </tbody>
            </table>
};

declare
function app:query_cerca( $query as xs:string, $fuzzy as xs:string?) {
    
    let $wildcard :=
        if ( not($fuzzy) ) then "*"
        else "~"

    let $query_filtrata := replace($query, "[&amp;&quot;-*;-`~!@#$%^*()_+-=\[\]\{\}\|';:/.,?(:]", "")
    let $query_con_wildcard := concat($query_filtrata, $wildcard)
    
    let $dati_persone := (
            doc( $config:app-root || "/xml/ida_marcheria.xml" )/tei:TEI/tei:text/tei:back/tei:listPerson//tei:person,
            doc( $config:app-root || "/xml/ida_marcheria.xml" )/tei:TEI/tei:teiHeader/tei:profileDesc/tei:particDesc/tei:listPerson//tei:person
        )

    for $hit in $dati_persone[ft:query(., $query_con_wildcard)]
    return $hit
    
};




declare
%templates:wrap
function app:query_form_testimone($node as node(), $model as map(*), $ricerca_ida_q as xs:string?, $ricerca_ida_parz as xs:string?) {
    let $no_query := not($ricerca_ida_q)
    return
        if ($no_query) then
            <br />
        else
            <table class="table table-striped table-borderless">
                <thead>
                    <tr><th colspan="4" scope="col">la ricerca di "{ $ricerca_ida_q }" ha prodotto { count(app:cerca_parole_enunciati_parlante("MARCHERIA", $ricerca_ida_q, $ricerca_ida_parz)) } risultati: </th></tr>
                    <!--tr>
                        <th scope="col">N</th>
                        <th scope="col"></th>
                    </tr-->
                </thead>
                <tbody>
                    {
                        
                        for $risultato at $i in app:cerca_parole_enunciati_parlante("MARCHERIA", $ricerca_ida_q, $ricerca_ida_parz)
                        return 
                            <tr>
                                <td>{ data($i) }</td>
                                <!--td>{ app:evidenzia_parola( data($risultato), $ricerca_ida_q) }</td-->
                                <td>{ $risultato }</td>
                            </tr>
                    }
                </tbody>
            </table>
};





declare
%templates:wrap
function app:ricerca_parole_persona($node as node(), $model as map(*), $ricerca_parole_persona_parlante as xs:string?, $ricerca_parole_persona_query as xs:string?, $ricerca_parole_persona_parz as xs:string?) {
    let $no_parlante := not($ricerca_parole_persona_parlante)
    let $no_query := not($ricerca_parole_persona_query)
    return
        if ($no_parlante) then
            <br />
        else if ($no_query) then
            <br />   
        else
            <table class="table table-striped table-borderless">
                <thead>
                    <tr>
                        <th colspan="4" scope="col">
                        la ricerca di "{ $ricerca_parole_persona_query }" per il parlante <i>{ app:nome_persona_da_id($ricerca_parole_persona_parlante) }</i>
                        ha prodotto { count(app:cerca_parole_enunciati_parlante($ricerca_parole_persona_parlante, $ricerca_parole_persona_query, $ricerca_parole_persona_parz)) } risultati: 
                        </th>
                    </tr>
                    <!--tr>
                        <th scope="col">N</th>
                        <th scope="col"></th>
                    </tr-->
                </thead>
                <tbody>
                    {
                        
                        for $risultato at $i in app:cerca_parole_enunciati_parlante($ricerca_parole_persona_parlante, $ricerca_parole_persona_query, $ricerca_parole_persona_parz)
                        return 
                            <tr>
                                <td>{ data($i) }</td>
                                <!--td>{ app:evidenzia_parola( data($risultato), $ricerca_ida_q) }</td-->
                                <td>{ $risultato }</td>
                            </tr>
                    }
                </tbody>
            </table>
};






declare
function app:cerca_parole_enunciati_parlante($parlante as xs:string, $query_u as xs:string, $parziale as xs:string?) {
    
    let $wildcard :=
        if ( not($parziale) ) then "" (: nessun wildcard = ricerca per parola esatta :)
        else "*" (: wildcard * = ricerca per parola anche parziale :)

    let $query_minuscolo := lower-case($query_u)
    let $query_filtrata := replace($query_minuscolo, "[&amp;&quot;-*;-`~!@#$%^*()_+-=\[\]\{\}\|';:/.,?(:]", "")
    let $query_con_wildcard := concat($query_filtrata, $wildcard)
    let $parlante_id := concat("#",$parlante)
    
    let $dati_u := doc( $config:app-root || "/xml/ida_marcheria.xml" )//tei:u[@who=$parlante_id]

    for $hit in $dati_u[ft:query(., $query_con_wildcard)]
    
    (: http://exist-db.org/exist/apps/doc/kwic#highlight :)
    let $expanded := util:expand($hit, "expand-xincludes=no")
    
    return app:formatta-match($expanded)
    
};

(: formatta ricorsivamente i figli e sotto-figli di un enunciato espanso con exist:match ottenuto da ricerche con lucene :) 
declare
function app:formatta-match($nodo_corrente as node()) {
    let $localName := $nodo_corrente/local-name()
    return 
        if ($localName = "" ) then
            <span class="testo_default"> { data($nodo_corrente) } </span>
        else
            if ($localName = "match" ) then
                <span class="evidenziato"> { data($nodo_corrente) } </span>
            else
                <span>
                    {
                        for $nodo_figlio in $nodo_corrente/node()
                        return app:formatta-match($nodo_figlio)
                    }
                </span>
};

(: funzione di risposta alla form mostra eventi e varianti per tipo :)
declare
%templates:wrap
function app:mostra_eventi($node as node(), $model as map(*), $tipo as xs:string?) {
    let $no_tipo := not($tipo)
    return
        if ($no_tipo) then
            <br />
        else
            <div>
                <b>Risultati per il tipo : { $tipo }</b>
                <p>Numero di occorrenze : { app:conta-elementi($tipo) }</p>
                <div>{ app:filtra-u-con-elementi($tipo) }</div>
            </div>


};

(: 
 : funzione di conteggio di elementi di un certo tipo all'interno del text body.
 : il tipo dell'elemento è passato come parametro stringa
:)
declare
function app:conta-elementi($tipo as xs:string) {
    let $elementi_filtrati :=
        for $elemento in doc( $config:app-root || "/xml/ida_marcheria.xml" )/tei:TEI/tei:text/tei:body//node()
        where $elemento//local-name() = $tipo
        return $elemento
    return count($elementi_filtrati)
};

(: 
 : funzione che filtra tutti gli elementi u che contengono un determinato tipo di elemento
 : il tipo dell'elemento è passato come parametro stringa
:)
declare
function app:filtra-u-con-elementi($tipo as xs:string) {
    for $elemento_u in doc( $config:app-root || "/xml/ida_marcheria.xml" )/tei:TEI/tei:text/tei:body//tei:u
    where $elemento_u//node()/local-name() = $tipo
    let $sigla := normalize-space( string-join((tokenize($elemento_u/@who, "#")[2], string(":"))))
    return 
        if (    $tipo ne "pause" 
                and $tipo ne "gap"
                and $tipo ne "shift"
            ) then
            <p> <span class="sigla">{ $sigla }</span> - { app:formatta_u_con_elementi($elemento_u, $tipo, "evidenziato") } -</p>
        else
            <p> <span class="sigla">{ $sigla }</span> - { app:formatta_u_con_elementi_invisibili($elemento_u, $tipo, app:formatta_nomi_elementi_invisibili($tipo)) } -</p>
};

(: formatta ricorsivamente i figli e sotto-figli di un enunciato evidenziando un particolare tipo di elemento
 : parametri : 
 : $tipo : il tipo dell'elemento da evidenziare
 : $classe : classe (stile) da utilizzare per l'evidenziazione 
:)
declare
function app:formatta_u_con_elementi($nodo_corrente as node(), $tipo as xs:string, $classe as xs:string) {
    let $localName := $nodo_corrente/local-name()
    return 
        if ($localName = "") then
            <span class="testo_default"> { data($nodo_corrente) } </span>
        else
            if ($localName = $tipo ) then
                <span class="{ $classe }"> { data($nodo_corrente) } </span>
            else
                <span>
                    {
                        for $nodo_figlio in $nodo_corrente/node()
                        return app:formatta_u_con_elementi($nodo_figlio, $tipo, $classe)
                    }
                </span>
};

(: formatta ricorsivamente i figli e sotto-figli di un enunciato evidenziando un particolare tipo di elemento (invisibile, che non contiene testo)
 : parametri : 
 : $tipo : il tipo dell'elemento da evidenziare
 : $sostituto : testo sostitutivo per rendere visibile l'elemento (es PAUSA)
:)
declare
function app:formatta_u_con_elementi_invisibili($nodo_corrente as node(), $tipo as xs:string, $sostituto as xs:string) {
    let $localName := $nodo_corrente/local-name()
    return 
        if ($localName = "") then
            <span class="testo_default"> { data($nodo_corrente) } </span>
        else
            if ($localName = $tipo ) then
                <span class="evidenziato"> { $sostituto } </span>
            else
                <span>
                    {
                        for $nodo_figlio in $nodo_corrente/node()
                        return app:formatta_u_con_elementi_invisibili($nodo_figlio, $tipo, $sostituto)
                    }
                </span>
};

(: formattazione nomi di eventi non visibili :)
declare
function app:formatta_nomi_elementi_invisibili($tipo as xs:string) {
    switch ($tipo) 
        case "pause" return " -PAUSA- "
        case "gap" return " -GAP- "
        case "shift" return " -CAMBIO DI TONO- "
        default return " - EVENTO DA DEFINIRE - " 
};






(: funzione test citazioni ida :)
declare
%templates:wrap
function app:ricerca_citazioni_testimone($node as node(), $model as map(*), $citato as xs:string?) {
    let $no_citato := not($citato)
    return
        if ($no_citato) then
            <br />
        else
            <table class="table table-striped table-borderless">
                <thead>
                    <tr><th colspan="2" scope="col">Risultati ricerca per { app:nome_persona_da_id($citato) }:</th></tr>
                </thead>
                <tbody>
                    {
                        let $citato_id := concat("#", $citato)
                        for $enunciato at $i in doc( $config:app-root || "/xml/ida_marcheria.xml" )/tei:TEI/tei:text/tei:body//tei:u[@who="#MARCHERIA"]/tei:persName[@ref=$citato_id]/..
                            return
                            <tr>
                                <td>{ $i }</td>
                                <td>{ app:formatta_u_con_elementi($enunciato, "persName", "evidenziato") }</td> 
                            </tr>
                    }
                </tbody>
            </table>
            
            
            
            
            

};

(: 
 :     where $enunciato//node()/local-name() = "persName" 
    return 
        <p>{ app:formatta_u_con_elementi($enunciato, "persName", "evidenziato") }</p>
 :  :)







(:  
declare
%templates:wrap
function app:nomilocali-figli-u($node as node(), $model as map(*)) {
    for $elemento in doc( $config:app-root || "/xml/ida_marcheria.xml" )/tei:TEI/tei:text/tei:body/*/tei:u//*
    return <li> {$elemento/local-name()} </li>

};
:)


(:                 
    local-name="{$localName}"
:)


(:
declare
function app:evidenzia_parola($data, $parola) {
    let $tokens := tokenize($data, $parola)
    for $token at $i in $tokens
    return
        if ($i = 1) then
            (count($tokens), $token)
        else
            (count($tokens), <b>{$parola}</b>, $token )
    
};
:)

(:  segnarsi problemi : se ricerco parola con maiuscola non va uso lowercase epr portare sempre tutto in minuscolo
 : evidenziazione non case sensitive (usare diversamente tokenize) :)


                

                

                
               
                














(:  

 : 
declare
function app:duration_pause_non_short() {
    let $elementi_pause := doc( $config:app-root || "/xml/ida_marcheria.xml" )/tei:TEI/tei:text/tei:body//tei:pause
    let $sequenza_durations := (
        for $elemento_pause in $elementi_pause
        where $elemento_pause/@type != "short"
        return 
            xs:duration($elemento_pause/@dur)
    )
    return $sequenza_durations
};

declare
function app:duration_pause() {
    let $elementi_pause := doc( $config:app-root || "/xml/ida_marcheria.xml" )/tei:TEI/tei:text/tei:body//tei:pause
    let $sequenza_durations := (
        for $elemento_pause in $elementi_pause
        return
            if ($elemento_pause[@dur]) then
                xs:duration($elemento_pause/@dur)
            else
              xs:duration("PT2.5S") (: media delle pause short, cioe che vanno da 0 a 4.9 secondi :)
    )
    return $sequenza_durations
};
:)





