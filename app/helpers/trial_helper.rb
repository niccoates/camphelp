module TrialHelper
  def trial_banner_for_campsite(campsite)
    return unless campsite&.trial?

    days_remaining = campsite.trial_days_remaining

    if days_remaining > 3
      render 'shared/trial_banner', campsite: campsite, days_remaining: days_remaining, urgency: 'info'
    elsif days_remaining > 0
      render 'shared/trial_banner', campsite: campsite, days_remaining: days_remaining, urgency: 'warning'
    else
      render 'shared/trial_banner', campsite: campsite, days_remaining: 0, urgency: 'danger'
    end
  end
end
