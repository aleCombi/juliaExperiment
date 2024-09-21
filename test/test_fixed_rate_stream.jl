using Test
using Dates
using DerivativesPricer

@testset "RateStream Tests" begin

    # Test 1: Test FixedRateStreamConfig creation
    @testset "FixedRateStreamConfig Tests" begin
        start_date = Date(2023, 1, 1)
        end_date = Date(2024, 1, 1)
        principal = 100000.0
        rate = 0.05
        schedule_config = ScheduleConfig(start_date, end_date, Monthly(), ACT360())
        rate_convention = Linear()

        # Create a FixedRateStreamConfig
        stream_config = FixedRateStreamConfig(principal, rate, schedule_config, rate_convention)

        # Test that the stream config was created correctly
        @test stream_config.principal == principal
        @test stream_config.rate == rate
        @test stream_config.schedule_config == schedule_config
        @test stream_config.rate_convention == rate_convention
    end

    # Test 2: Test schedule generation and accrual dates in FixedRateStream
    @testset "FixedRateStream Schedule Generation" begin
        start_date = Date(2023, 1, 1)
        end_date = Date(2024, 1, 1)
        principal = 100000.0
        rate = 0.05
        schedule_config = ScheduleConfig(start_date, end_date, Monthly(), ACT360())
        rate_convention = Linear()

        # Create a FixedRateStreamConfig
        stream_config = FixedRateStreamConfig(principal, rate, schedule_config, rate_convention)

        # Generate the FixedRateStream
        stream = FixedRateStream(stream_config)

        # Expected number of accrual dates (12 months)
        expected_dates = generate_schedule(start_date, end_date, Monthly()) |> collect

        # Check that the generated accrual dates match the expected dates
        @test stream.accrual_dates == expected_dates
    end

    # Test 3: Test cash flow generation in FixedRateStream
    @testset "FixedRateStream Cash Flow Calculation" begin
        start_date = Date(2023, 1, 1)
        end_date = Date(2024, 1, 1)
        principal = 100000.0
        rate = 0.05  # 5% interest
        schedule_config = ScheduleConfig(start_date, end_date, Monthly(), ACT360())
        rate_convention = Linear()

        # Create a FixedRateStreamConfig
        stream_config = FixedRateStreamConfig(principal, rate, schedule_config, rate_convention)

        # Generate the FixedRateStream
        stream = FixedRateStream(stream_config)

        # Check that the cash flows are calculated correctly
        # For ACT/360, we need the actual number of days in each month to calculate the time fraction
        months = 1:12
        actual_days_in_month = [daysinmonth(Date(2023, m, 1)) for m in months]
        
        # Calculate the time fraction for each month (actual days / 360)
        time_fractions = actual_days_in_month ./ 360.0
        
        # Calculate the expected cash flows
        expected_cash_flows = principal .* rate .* time_fractions

        @test length(stream.cash_flows) == 12  # Ensure there are 12 cash flows
        @test stream.cash_flows ≈ expected_cash_flows  # Ensure cash flows are as expected
    end

    # Test 4: Edge case with zero principal
    @testset "Edge Case: Zero Principal" begin
        start_date = Date(2023, 1, 1)
        end_date = Date(2024, 1, 1)
        principal = 0.0  # Zero principal
        rate = 0.05
        schedule_config = ScheduleConfig(start_date, end_date, Monthly(), ACT360())
        rate_convention = Linear()

        # Create a FixedRateStreamConfig
        stream_config = FixedRateStreamConfig(principal, rate, schedule_config, rate_convention)

        # Generate the FixedRateStream
        stream = FixedRateStream(stream_config)

        # Cash flows should all be zero
        expected_cash_flows = fill(0.0, 12)
        
        @test stream.cash_flows == expected_cash_flows  # Cash flows should all be zero
    end

    # Test 5: Edge case with different day count convention (ACT/365)
    @testset "Edge Case: ACT/365 Day Count Convention" begin
        start_date = Date(2023, 1, 1)
        end_date = Date(2024, 1, 1)
        principal = 100000.0
        rate = 0.05
        schedule_config = ScheduleConfig(start_date, end_date, Monthly(), ACT365())
        rate_convention = Linear()

        # Create a FixedRateStreamConfig
        stream_config = FixedRateStreamConfig(principal, rate, schedule_config, rate_convention)

        # Generate the FixedRateStream
        stream = FixedRateStream(stream_config)

        # For ACT/365, we need the actual number of days in each month to calculate the time fraction
        months = 1:12
        actual_days_in_month = [daysinmonth(Date(2023, m, 1)) for m in months]
        
        # Calculate the time fraction for each month (actual days / 365)
        time_fractions = actual_days_in_month ./ 365.0
        
        # Calculate the expected cash flows
        expected_cash_flows = principal .* rate .* time_fractions

        @test stream.cash_flows ≈ expected_cash_flows  # Ensure cash flows are calculated correctly
    end

end