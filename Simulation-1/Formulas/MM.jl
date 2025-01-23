# MM1

mutable struct queueKeyParameters
    lambda::Float64
    mu::Float64
    n::Int64
    p::Float64
    P0::Float64
    Pn::Float64
    L::Float64
    Lq::Float64
    W::Float64
    Wq::Float64

    function queueKeyParameters(
        lambda::Float64,
        mu::Float64,
        n::Int64
        )

        return new(
            lambda,
            mu,
            n
        )
    end
end 

function calcuclate_MM1(self::queueKeyParameters)
    self.p = self.lambda / self.mu
    self.P0 = 1 - self.p
    self.Pn = (1-self.p) * self.p^(self.n)
    self.L = self.lambda / (self.mu -self.lambda)
    self.Lq = self.lambda^2 / (self.mu * (self.mu - self.lambda))
    self.W = 1 / (self.mu - self.lambda)
    self.Wq = self.lambda / (self.mu * (self.mu - self.lambda))

    return self
end

function calculate_MMS(self::queueKeyParameters, servers::Int64)

    self.p = self.lambda / (self.mu*servers)

    alfa = self.lambda / self.mu
    part_1 = sum([(alfa)^(i) * factorial(i) for i in 0:servers-1])
    part_2 = (alfa^(servers)) / factorial(servers)
    part_3 = (1-(alfa/servers))^(-1)
    self.P0 = (part_1 + part_2 * part_3)^(-1)
       
    if self.n >= servers
        self.Pn = ((self.lambda / self.mu)^self.n / (factorial(servers) * (servers)^(self.n-servers))) * self.P0
    else
        self.Pn = ((self.lambda/self.mu)^self.n / factorial(self.n)) * self.P0
    end
    self.Lq = (self.P0 * ((self.lambda/self.mu)^servers) * self.p) / (factorial(servers) * ((1 - self.p)^2))
    self.L = self.Lq + (self.lambda / self.mu)
    self.Wq = self.Lq / self.lambda
    self.W = self.Wq + (1 / self.mu)
    
    return self
end