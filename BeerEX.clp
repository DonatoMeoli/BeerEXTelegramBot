
;;;===========================================================================
;;; BeerEX: the Beer EXpert system
;;;
;;;   This expert system suggests a beer to drink according to taste and meal.
;;;
;;;   CLIPS 6.31
;;;
;;;   Author: Donato Meoli
;;;===========================================================================

(load clips/beerex.clp)

(undefrule load-beer-question-rules)
(load clips/beer-questions.clp)

(undefrule load-beer-knowledge-rules)
(load clips/beer-knowledge.clp)

(deffunction ask-question (?display ?allowed-values)
   (bind ?answer "")
   (if (or (not (member$ prev ?allowed-values))
           (member$ restart ?allowed-values))
    then (printout t crlf))
   (while (not (member$ ?answer ?allowed-values))
      (printout t ?display crlf)
      (bind ?i 1)
      (progn$ (?value ?allowed-values)
              (printout t ?i "." ?value " ")
              (bind ?i (+ ?i 1)))
      (printout t crlf)
      (printout t "Answer: ")
      (if (neq (bind ?number (read-number)) "*** READ ERROR ***")
       then (bind ?answer (nth$ ?number ?allowed-values)))
      (printout t crlf))
   ?answer)

(deffunction next-UI-state ()
   (do-for-fact ((?s state-list)) TRUE (and (bind ?current-id ?s:current)
                                            (bind ?sequence ?s:sequence)))
   (do-for-fact ((?u UI-state)) (eq ?u:id ?current-id) (and (bind ?display ?u:display) (bind ?state ?u:state)
                                                            (bind ?help ?u:help) (bind ?why ?u:why)
                                                            (bind ?valid-answers ?u:valid-answers)))
   (if (eq ?state middle)
    then (bind ?allowed-values ?valid-answers)
         (if (neq ?help nil)
          then (bind ?allowed-values (insert$ ?allowed-values (+ (length$ ?allowed-values) 1) help)))
         (if (neq ?why nil)
          then (bind ?allowed-values (insert$ ?allowed-values (+ (length$ ?allowed-values) 1) why)))
         (bind ?allowed-values (insert$ ?allowed-values (+ (length$ ?allowed-values) 1) cancel))
         (if (> (length$ ?sequence) 2)
          then (bind ?allowed-values (insert$ ?allowed-values (length$ ?allowed-values) prev)))
         (bind ?answer (ask-question ?display ?allowed-values))
    else (if (eq ?state final)
          then (bind ?answer (ask-question ?display (create$ prev restart cancel)))
          else (assert (next ?current-id))
               (run)
               (next-UI-state)))
   (if (member$ ?answer ?valid-answers)
    then (assert (next ?current-id ?answer))
         (run)
         (next-UI-state)
    else (if (eq ?answer help)
          then (printout t crlf)
               (printout t ?help crlf)
               (printout t crlf)
               (next-UI-state))
         (if (eq ?answer why)
          then (printout t crlf)
               (printout t ?why crlf)
               (printout t crlf)
               (next-UI-state))
         (if (eq ?answer prev)
          then (assert (prev ?current-id))
               (run)
               (next-UI-state))
         (if (eq ?answer restart)
          then (reset)
               (run)
               (next-UI-state))
         (if (eq ?answer cancel)
          then (exit))))

(reset)
(run)

(next-UI-state)
