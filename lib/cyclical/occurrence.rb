require 'cyclical/suboccurrence'

module Cyclical
  # Holds an occurence of a recurrence rule, can compute next and previous and list occurrences
  class Occurrence

    attr_reader   :rule, :start_time
    attr_accessor :duration

    def initialize(rule, start_time)
      @rule = rule
      @start_time = @rule.match?(start_time, start_time) ? start_time : @rule.next(start_time, start_time)
    end

    def next_occurrence(after)
      next_occurrences(1, after).first
    end

    def next_occurrences(n, after)
      return [] if @rule.stop && after > @rule.stop
      time = (after <= @start_time ? @start_time : after)
      time = @rule.next(time, @start_time) unless @rule.match?(time, @start_time)

      list_occurrences(time) { (n -= 1) >= 0 }
    end

    def previous_occurrence(before)
      previous_occurrences(1, before).first
    end

    def previous_occurrences(n, before)
      return [] if before <= @start_time
      time = (@rule.stop.nil? || before < @rule.stop ? before : @rule.stop)
      time = @rule.previous(time, @start_time) # go back even if before matches the rule (half-open time intervals, remember?)

      list_occurrences(time, :back) { (n -= 1) >= 0 }.reverse
    end

    def occurrences_between(t1, t2)
      raise ArgumentError, "Empty time interval" unless t2 > t1
      return [] if t2 <= @start_time || @rule.stop && t1 >= @rule.stop

      time = (t1 <= @start_time ? @start_time : t1)
      time = @rule.next(time, @start_time) unless @rule.match?(time, @start_time)

      list_occurrences(time) { |t| t < t2 }
    end

    def suboccurrences_between(t1, t2)
      occurrences = occurrences_between(t1 - duration, t2)
      occurrences.map { |occ| Suboccurrence.find(:occurrence => (occ)..(occ + duration), :interval => t1..t2) }
    end

    def all
      if @rule.stop
        list_occurrences(@start_time) { |t| t < @rule.stop }
      else
        n = @rule.count
        list_occurrences(@start_time) { (n -= 1) >= 0 }
      end
    end

    def to_hash
      @rule.to_hash
    end

    private

    # yields valid occurrences, return false from the block to stop
    def list_occurrences(from, direction = :forward, &block)
      raise ArgumentError, "From #{from} not matching the rule #{@rule} and start time #{@start_time}" unless @rule.match?(from, @start_time)

      results = []

      n, current = init_loop(from, direction)
      loop do
        # Rails.logger.debug("Listing occurrences of #{@rule}, going #{direction.to_s}, current: #{current}")
        # break on schedule span limits
        return results unless (current >= @start_time) && (@rule.stop.nil? || current < @rule.stop) && (@rule.count.nil? || (n -= 1) >= 0)

        # break on block condition
        return results unless yield current

        results << current

        # step
        if direction == :forward
          current = @rule.next(current, @start_time)
        else
          current = @rule.previous(current, @start_time)
        end
      end
    end

    def init_loop(from, direction)
      return 0, from unless @rule.count # without count limit, life is easy

      # with it, it's... well...
      if direction == :forward
        n = 0
        current = @start_time
        while current < from
          n += 1
          current = @rule.next(current, @start_time)
        end

        # return the n remaining events
        return (@rule.count - n), current
      else
        n = 0
        current = @start_time
        while current < from && (n += 1) < @rule.count
          current = @rule.next(current, @start_time)
        end

        # return all events (downloop - yaay, I invented a word - will stop on start time)
        return @rule.count, current
      end
    end
  end
end
