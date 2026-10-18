<!--
   The MIT License

   Copyright (c) 2019- Nordic Institute for Interoperability Solutions (NIIS)
   Copyright (c) 2018 Estonian Information System Authority (RIA),
   Nordic Institute for Interoperability Solutions (NIIS), Population Register Centre (VRK)
   Copyright (c) 2015-2017 Estonian Information System Authority (RIA), Population Register Centre (VRK)

   Permission is hereby granted, free of charge, to any person obtaining a copy
   of this software and associated documentation files (the "Software"), to deal
   in the Software without restriction, including without limitation the rights
   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
   copies of the Software, and to permit persons to whom the Software is
   furnished to do so, subject to the following conditions:

   The above copyright notice and this permission notice shall be included in
   all copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
   THE SOFTWARE.
 -->
<template>
  <div class="xrd-logo" data-test="app-logo" @click="routing?.toHome()">
    <img :src="coatOfArmsUrl" alt="Coat of arms of Lesotho" class="coat-of-arms" />
    <span class="wordmark">
      <span class="wordmark-name">{{ $t('branding.name') }}</span>
      <span class="wordmark-sub">{{ $t('branding.country') }}</span>
    </span>
  </div>
</template>

<script lang="ts" setup>
import coatOfArms from '../assets/coat_of_arms.png';
import { inject } from 'vue';
import { key } from '../utils';

const coatOfArmsUrl = coatOfArms;

const routing = inject(key.routing);
</script>

<style lang="scss" scoped>
@use '../assets/colors';

.xrd-logo {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-top: auto;
  margin-bottom: auto;
  cursor: pointer;
  user-select: none;
  @media only screen and (max-width: 920px) {
    display: none;
  }

  .coat-of-arms {
    height: 40px;
    width: auto;
  }

  .wordmark {
    display: flex;
    flex-direction: column;
    line-height: 1.1;
    text-transform: uppercase;
    white-space: nowrap;
  }

  .wordmark-name {
    color: colors.$Purple100;
    font-weight: 800;
    font-size: 14px;
    letter-spacing: 0.06em;
  }

  .wordmark-sub {
    color: colors.$Black70;
    font-weight: 600;
    font-size: 9px;
    letter-spacing: 0.14em;
  }
}
</style>
