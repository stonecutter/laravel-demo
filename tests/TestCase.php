<?php

namespace Tests;

use Carbon\Carbon;
use Illuminate\Foundation\Testing\TestCase as BaseTestCase;
use Illuminate\Foundation\Testing\WithFaker;
use Illuminate\Support\Facades\Cache;

abstract class TestCase extends BaseTestCase
{
    use CreatesApplication;
    use WithFaker;

    protected function setUp()
    {
        parent::setUp();
        Carbon::setTestNow(now());
        config(['cache.default' => 'redis']);
    }

    protected function tearDown()
    {
        Cache::flush();
        parent::tearDown();
    }
}
