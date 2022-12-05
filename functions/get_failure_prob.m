function p_failure = get_failure_prob(age, model)

 p_failure = 1./(1 + exp(-model(3)*1.1*(age-model(1)*.95)));

end
